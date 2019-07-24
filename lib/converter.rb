require 'json'
require 'securerandom'

module Converter

class OCDS
  def self.ToJSON(opportunities)
    json = {
      publisher: 'SPA',

      license: 'http://open.canada.ca/en/open-government-licence-canada',
      license_fr: 'http://ouvert.canada.ca/fr/licence-du-gouvernement-ouvert-canada',

      extensions: %w(
        https://github.com/open-contracting-extensions/ocds_options_extension
        https://github.com/open-contracting-extensions/ocds_recurrence_extension
        https://github.com/open-contracting-extensions/ocds_additionalContactPoints_extension
        https://github.com/open-contracting-extensions/ocds_coveredBy_extension
        https://github.com/open-contracting-extensions/ocds_procurementMethodModalities_extension
      ),

      releases: []
    }

    opportunities.each do |op|
      json[:releases] << {
        ocid: op.ocid,
        initiationType: 'tender',
        language: 'en',
        parties: [op.procuring_entity.ToPartiesOCDS],
        tender: op.ToOCDS
      }
    end

    JSON.pretty_generate(json)
  end
end

class Opportunity
  attr_accessor :ocid, :tender_id, :title_en, :title_fr,
    :description_en, :description_fr, :proc_method_en, :proc_method_fr,
    :proc_method_details_en, :proc_method_details_fr, :submission_method,
    :submission_method_details_en, :submission_method_details_fr,
    :eligibility_criteria_en, :eligibility_criteria_fr, :award_criteria,
    :award_criteria_details_en, :award_criteria_details_fr, :options_en,
    :options_fr, :agreements, :recurrence_description_en,
    :recurrence_description_fr, :rfp_date, :rfp_description_en,
    :rfp_description_fr, :use_electronic_auction, :is_negotiated

  attr_reader :tender_period, :contract_period, :recurrence_period,
    :procuring_entity, :items, :delivery_period

  def initialize
    @procuring_entity = ProcuringEntity.new
    @tender_period = Dates.new
    @contract_period = Dates.new
    @recurrence_period = Dates.new
    @delivery_period = Dates.new
    @items = []
  end

  # TODO(dsinclair). If the opportunity only has french content then we're going
  # to set the language to en but skip writing any of the default fields. We
  # should detect that we only have fr content, set the language correctly and
  # write the french into the default fields.
  def ToOCDS
    ret = { id: @tender_id, }

    ret[:procuringEntity] = @procuring_entity.ToProcuringEntityOCDS if @procuring_entity.has_data?

    if !@title_en.blank?
      ret[:title] = @title_en
    else
      ret[:title] = @description_en[0..128]
      ret[:title] += "..." if @description_en.length > 128
    end

    if !@title_fr.blank?
      ret[:title_fr] = @title_fr
    elsif !@description_fr.blank?
      ret[:title_fr] = @description_fr[0..128]
      ret[:title_fr] += "..." if @description_fr.length > 128
    end

    ret[:description] = @description_en unless @description_en.blank?
    ret[:description_fr] = @description_fr unless @description_fr.blank?

    ret[:contractPeriod] = @contract_period.ToOCDS if @contract_period.has_data?
    ret[:tenderPeriod] = @tender_period.ToOCDS if @tender_period.has_data?

    if @recurrence_period.has_data? || !@recurrence_description_en.blank? ||
        !@recurrence_description_fr.blank?
      ret[:recurrence] = {}

      ret[:recurrence][:dates] = [@recurrence_period.ToOCDS] if @recurrence_period.has_data?
      ret[:recurrence][:description] =
          @recurrence_description_en unless @recurrence_description_en.blank?
      ret[:recurrence][:description_fr] =
          @recurrence_description_fr unless @recurrence_description_fr.blank?
    end

    ret[:options] = @options_en unless @options_en.blank?
    ret[:options_fr] = @options_fr unless @options_fr.blank?

    ret[:items] = @items.collect { |i| i.ToOCDS } unless @items.empty?

    if !@rfp_date.blank? || !@rfp_description_en.blank? || !@rfp_description_fr.blank?
      rfp = { type: :requestToParticipate}
      rfp[:dueDate] = @rfp_date unless @rfp_date.blank?
      rfp[:description] = @rfp_description_en unless @rfp_description_en.blank?
      rfp[:description_fr] = @rfp_description_fr unless @rfp_description_fr.blank?

      ret[:milestones] ||= []
      ret[:milestones] << rfp
    end

    if @delivery_period.has_data?
      del = { type: :delivery }
      del[:dueDate] = @deliver_period.max_date unless @deliver_perid.max_date.blank?
      if !@delivery_period.start_date.blank? || !@delivery_period.end_date.blank?
        del[:period] = {}
        del[:period][:startDate] = @delivery_period.start_date unless @delivery_period.start_date.blank?
        del[:period][:endDate] = @delivery_period.end_date unless @delivery_period.end_date.blank?
      end
      ret[:milestones] ||= []
      ret[:milestones] << del
    end

    if !@use_electronic_auction.blank? || !@is_negotiated.blank?
      rel[:procurementMethodModalities] = []
      ret[:procurementMethodModalities] << :electronicAuction unless @use_electronic_auction.blank? || !@use_electronic_auction
      ret[:procurementMethodModalities] << :negotiated unless @negotiated.blank? || !@negotiated
    end

    ret[:awardCriteria] = @award_criteria unless @award_criteria.blank?
    ret[:awardCriteriaDetails] =
        @award_criteria_details_en unless @award_criteria_details_en.blank?
    ret[:awardCriteriaDetails_fr] =
        @award_criteria_details_fr unless @award_criteria_details_fr.blank?

    ret[:eligibilityCriteria] =
        @eligibility_criteria_en unless @eligibiltiy_criteria_en.blank?
    ret[:eligibilityCriteria_fr] =
        @eligibility_criteria_fr unless @eligibiltiy_criteria_fr.blank?

    ret[:procurementMethod] = @proc_method_en unless @proc_method_en.blank?
    ret[:procurementMethod_fr] = @proc_method_fr unless @proc_method_fr.blank?

    ret[:procurementMethodDetails] =
        @proc_method_details_en unless @proc_method_details_en.blank?
    ret[:procurementMethodDetails_fr] =
        @proc_method_details_fr unless @proc_method_details_fr.blank?

    ret[:submissionMethod] = @submission_method unless @submission_method.blank?
    ret[:submissionMethodDetails] =
        @submission_method_details_en unless @submission_method_details_en.blank?
    ret[:submissionMethodDetails_fr] =
        @submission_method_details_fr unless @submission_method_details_fr.blank?

    ret[:coveredBy] = @agreements unless @agreements.nil? || @agreements.empty?
    ret
  end
end

class ProcuringEntity
  attr_accessor :name_en, :name_fr, :addr, :city, :province, :postal_code
  attr_reader :contact

  def initialize
    @contact = Contact.new
    @id = SecureRandom.uuid
  end

  def has_data?
    @contact.has_data? || !@name_en.blank? || !@name_fr.blank? || !@addr.blank? ||
        !@city.blank? || !@province.blank? || !@postal_code.blank?
  end

  def ToPartiesOCDS
    ret = {}
    ret[:id] = @id
    ret[:roles] = ['procuringEntity']
    ret[:name] = @name_en unless @name_en.blank?
    ret[:name_fr] = @name_fr unless @name_fr.blank?

    if !@addr.blank? || !@city.blank? || !@province.blank? || !@postal_code.blank?
      address = {}
      address[:streetAddress] = @addr unless @addr.blank?
      address[:locality] = @city unless @city.blank?
      address[:region] = @province unless @province.blank?
      address[:postalCode] = @postal_code unless @postal_code.blank?
      ret[:address] = address
    end
    ret
  end

  def ToProcuringEntityOCDS
    ret = {}
    ret[:id] = @id
    ret[:name] = @name_en unless @name_en.blank?
    ret[:name_fr] = @name_fr unless @name_fr.blank?
    ret[:contactPoint] = contact.ToOCDS if contact.has_data?
    ret
  end
end

class Contact
  attr_accessor :name, :email, :phone, :fax, :url, :languages

  def initialize
    @languages = []
  end

  def has_data?
    !@name.blank? || !@email.blank? || !@phone.blank? || !@fax.blank? ||
      !@url.blank? || !@languages.empty?
  end

  def ToOCDS
    ret = { name: @name }
    ret[:email] = @email unless @email.blank?
    ret[:telephone] = @phone unless @phone.blank?
    ret[:faxNumber] = @fax unless @fax.blank?
    ret[:url] = @url unless @url.blank?
    ret[:additionalLanguages] = @languages unless @languages.empty?
    ret
  end
end

class Dates
  attr_accessor :start_date, :end_date, :max_date, :duration_in_days

  def has_data?
    return !@start_date.blank? || !@end_date.blank? || !@max_date.blank? ||
        !@duration_in_days.blank?
  end

  def ToOCDS
    ret = {}
    ret[:startDate] = @start_date.iso8601 unless @start_date.blank?
    ret[:endDate] = @end_date.iso8601 unless @end_date.blank?
    ret[:maxExtentDate] = @max_date.iso8601 unless @max_date.blank?
    ret[:durationInDays] = @duration_in_days.to_i unless @duration_in_days.blank?
    ret
  end
end

class Item
  attr_accessor :id, :description_en, :description_fr, :quantity, :units_en, :units_fr

  def ToOCDS
    ret = { id: @id }
    ret[:description] = @description_en unless @description_en.blank?
    ret[:description_fr] = @description_fr unless @description_fr.blank?
    ret[:quantity] = @quantity.to_i  unless @quantity.blank?
    ret[:units] = @units_en unless @units_en.blank?
    ret[:units_fr] = @units_fr unless @units_fr.blank?
    ret
  end
end

autoload :Alberta, 'converter/alberta'
autoload :BritishColumbia, 'converter/british_columbia'
autoload :FederalGovernment, 'converter/federal_government'
autoload :NovaScotia, 'converter/nova_scotia'
autoload :Nunavut, 'converter/nunavut'
autoload :Quebec, 'converter/quebec'
autoload :Yukon, 'converter/yukon'

end  # Converter
