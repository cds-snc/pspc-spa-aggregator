#!/usr/bin/env ruby

require 'open-uri'

PARAMS="ss_publishing_status=SDS-SS-005&sm_facet_procurement_data=data_data_tender_notice"

BAS_EN_RSS="https://buyandsell.gc.ca/procurement-data/feed?"
BAS_FR_RSS="https://achatsetventes.gc.ca/donnees-sur-l-approvisionnement/feed?ss_language=fr&"

docs= {}
if ARGV.size < 2
  docs[:en] = open("#{BAS_EN_RSS}#{PARAMS}")
  docs[:fr] = open("#{BAS_FR_RSS}#{PARAMS}")
else
  docs[:en] = File.open(ARGV[0]).read
  docs[:fr] = File.open(ARGV[1]).read
end

def process(lang, doc, keys, data)
  doc.xpath("//channel/item").each do |item|
    title = item.xpath('title').text.strip
    link = item.xpath('link').text.strip
    # The <pubDate> appears to be the latest publication date of the record, so
    # if there are ammendments, it ends up being that date. The actual publication
    # date is in the description 'Publication Date'
    # pub_date = item.xpath('//pubDate').text

    creator = item.xpath('dc:creator').text.strip
    # The <guid> field changes as it has a date attached to it. The date will
    # change due to amendments so it can't be used as an identifier for this
    # procurement.
    # guid = item.xpath('guid').text.strip

    description = {}

    desc_html = Nokogiri::HTML(item.xpath('description').text)
    desc_html.xpath('//table/tbody/tr').each do |tr|
      type = tr.children[0].text.strip

      body = tr.children[1]
      body.css('br').each { |br| br.replace("\n") }
      value = body.text.strip

      description[type.downcase] = value
    end

    # Ignore non-active postings
    #
    # TODO(dsinclair) This probably needs to be handled so listings can be removed
    # when they become in-active if it's before the closing date.
    next unless description[keys[:status]] == keys[:active]

    # There is no real description so fake it at the moment. If categories are
    # added the GSIN should move there instead of description.
    desc = "#{keys[:gsin]}: #{description[keys[:gsin_desc]]}\n\n"

    if !description[keys[:delivery_region]].nil? &&
        description[keys[:delivery_region]] != ''
      desc += "#{keys[:delivery_region]}: #{description[keys[:delivery_region]]}\n"
    end

    if !description[keys[:op_region]].nil? &&
        description[keys[:op_region]] != ''
      desc += "#{keys[:op_region]}: #{description[keys[:op_region]]}"
    end

    uuid = link.split(/\//).last

    data[uuid] ||= {}
    data[uuid][lang] = {
      title: title,
      link: link,
      creator: creator,
      guid: link,
      closing_date: description[keys[:date_closing]],
      description: desc,
      procuring_entity: description[keys[:entity]]
    }
  end
end

KEYS = {
  en: {
    active: 'Active',
    gsin: 'GSIN',
    status: 'publishing status',
    gsin_desc: 'gsin description',
    delivery_region: 'region of delivery',
    op_region: 'region of opportunity',
    amend_date: 'amendment date',
    date_closing: 'date closing',
    type: 'notice type',
    entity: 'procurement entity',
    pub_date: 'publication date'
  },
  fr: {
    active: 'Actif',
    gsin: 'NIBS',
    status: 'état de publication',
    gsin_desc: 'description du nibs',
    delivery_region: "région de l'avis d'appel d'offres",
    op_region: 'région de livraison',
    amend_date: 'date de modification',
    date_closing: 'date de fermeture',
    type: "type d'avis",
    entity: 'entité responsable des achats',
    pub_date: 'date de publication'
  }
}

data = {}
[:en, :fr].each do |k|
  process(k, Nokogiri::XML(docs[k]), KEYS[k], data)
end

releases = []
data.each_pair do |uuid, values|
  if !values.has_key?(:en) || !values.has_key?(:fr)
    pp values
    next
  end

  pe = {
    id: values[:en][:procuring_entity],
    name: values[:en][:procuring_entity],
    name_fr: values[:fr][:procuring_entity]
  }

  tender = {
    id: values[:en][:guid],
    title: values[:en][:title],
    title_fr: values[:fr][:title],
    description: values[:en][:description],
    description_fr: values[:fr][:description],
    procuringEntity: pe,
    tenderPeriod: {
      endDate: values[:en][:closing_date]
    }
  }

  releases << {
    ocid: values[:en][:link],
    initiationType: 'tender',
    language: 'en',
    tender: tender,
    buyer: {
      name: values[:en][:creator],
      name_fr: values[:fr][:creator]
    }
  }
end

json = {
  publisher: 'BuyAndSell RSS Converter',

  license: 'http://open.canada.ca/en/open-government-licence-canada',
  license_fr: 'http://ouvert.canada.ca/fr/licence-du-gouvernement-ouvert-canada',

  extensions: %w(
    https://github.com/open-contracting-extensions/ocds_options_extension
    https://github.com/open-contracting-extensions/ocds_recurrence_extension
    https://github.com/open-contracting-extensions/ocds_additionalContactPoints_extension
    https://github.com/open-contracting-extensions/ocds_coveredBy_extension
  )
}
json[:releases] = releases

pp json
