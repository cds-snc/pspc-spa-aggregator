require 'test_helper'
require 'converter'

class ConverterTest < ActiveSupport::TestCase
  test 'Item::ToOCDS' do
    i = Converter::Item.new
    i.id = 1
    i.description_en = 'English description'
    i.description_fr = 'Description Française'
    i.quantity = 5
    i.units_en = 'houses'
    i.units_fr = 'maisons'

    ocds = i.ToOCDS
    assert_equal ocds[:id], 1
    assert_equal ocds[:description], 'English description'
    assert_equal ocds[:description_fr], 'Description Française'
    assert_equal ocds[:quantity], 5
    assert_equal ocds[:units], 'houses'
    assert_equal ocds[:units_fr], 'maisons'
  end

  test 'Item::ToOCDS handles missing fields' do
    i = Converter::Item.new
    i.id = 5

    ocds = i.ToOCDS
    assert_equal ocds[:id], 5
    assert_not ocds.has_key?(:description)
    assert_not ocds.has_key?(:description_fr)
    assert_not ocds.has_key?(:quantity)
    assert_not ocds.has_key?(:units)
    assert_not ocds.has_key?(:units_fr)
  end

  test 'Dates::has_data? when empty' do
    d = Converter::Dates.new
    assert_not d.has_data?
  end

  [:start_date, :end_date, :max_date, :duration_in_days].each do |val|
    test "Dates::has_data? with #{val}" do
      d = Converter::Dates.new
      d.send("#{val}=", "value")

      assert d.has_data?
    end
  end

  test 'Dates::ToOCDS' do
    d = Converter::Dates.new
    d.start_date = DateTime.parse('2019-05-05 11:59 PM')
    d.end_date = Date.parse('May 5, 2020')
    d.max_date = Date.parse('2025-05-05')
    d.duration_in_days = 100

    ocds = d.ToOCDS
    assert_equal ocds[:startDate], '2019-05-05T23:59:00+00:00'
    assert_equal ocds[:endDate], '2020-05-05'
    assert_equal ocds[:maxExtentDate], '2025-05-05'
    assert_equal ocds[:durationInDays], 100
  end

  test 'Dates::ToOCDS displays duration as an integer' do
    d = Converter::Dates.new
    d.duration_in_days = '100'

    ocds = d.ToOCDS
    assert_equal ocds[:durationInDays], 100
    assert ocds[:durationInDays].is_a?(Integer)
  end

  test 'Dates::ToOCDS handles missing fields' do
    d = Converter::Dates.new

    ocds = d.ToOCDS
    assert ocds.empty?
  end

  test 'Contact::ToOCDS' do
    c = Converter::Contact.new
    c.name = 'Test Contact'
    c.email = 'test@example.com'
    c.phone = '555-555-5555'
    c.fax = '444-444-4444'
    c.url = 'test.example.com/test'
    c.languages = ['en', 'fr']

    ocds = c.ToOCDS
    assert_equal ocds[:name], 'Test Contact'
    assert_equal ocds[:telephone], '555-555-5555'
    assert_equal ocds[:faxNumber], '444-444-4444'
    assert_equal ocds[:url], 'test.example.com/test'
    assert_equal ocds[:additionalLanguages], ['en', 'fr']
  end

  test 'Contact::has_data? when empty' do
    c = Converter::Contact.new
    assert_not c.has_data?
  end

  [:name, :email, :phone, :fax, :url].each do |val|
    test "Contact has_data? with #{val}" do
      c = Converter::Contact.new
      c.send("#{val}=", "test value")
      assert c.has_data?
    end
  end

  test "Contact has_data? with languages" do
    c = Converter::Contact.new
    c.languages << "en"
    assert c.has_data?
  end

  test 'Contact::ToOCDS skips blank fields' do
    c = Converter::Contact.new
    c.name = 'Contact Name'

    ocds = c.ToOCDS
    assert_not ocds.has_key?(:email)
    assert_not ocds.has_key?(:telephone)
    assert_not ocds.has_key?(:faxNumber)
    assert_not ocds.has_key?(:url)
    assert_not ocds.has_key?(:additionalLanguages)
  end

  test 'ProcuringEntity::ToPartiesOCDS' do
    p = Converter::ProcuringEntity.new
    p.name_en = 'Test Entity'
    p.name_fr = 'Entité de test'
    p.addr = '123 Streets Way'
    p.city = 'Somewhere Ville'
    p.province = 'Ontario'
    p.postal_code = 'Z9Z 9Z9'
    p.contact.name = 'Contact Person'
    p.contact.email = 'test@example.com'
    p.contact.url = 'test.example.com/contact'

    ocds = p.ToPartiesOCDS
    assert_not ocds[:id].blank?
    assert_not ocds.has_key?(:contactPoint)
    assert_equal ocds[:roles], ['procuringEntity']
    assert_equal ocds[:name], 'Test Entity'
    assert_equal ocds[:name_fr], 'Entité de test'
    assert_equal ocds[:address][:streetAddress], '123 Streets Way'
    assert_equal ocds[:address][:locality], 'Somewhere Ville'
    assert_equal ocds[:address][:region], 'Ontario'
    assert_equal ocds[:address][:postalCode], 'Z9Z 9Z9'
  end

  test 'ProcuringEntity::ToPartiesOCDS skips blank fields' do
    p = Converter::ProcuringEntity.new

    ocds = p.ToPartiesOCDS
    assert_not ocds[:id].blank?
    assert_equal ocds[:roles], ['procuringEntity']
    assert_not ocds.has_key?(:name)
    assert_not ocds.has_key?(:name_fr)
    assert_not ocds.has_key?(:address)
    assert_not ocds.has_key?(:contactPoint)
  end

  test 'ProcuringEntity::ToProcuringEntityOCDS' do
    p = Converter::ProcuringEntity.new
    p.name_en = 'Test Entity'
    p.name_fr = 'Entité de test'
    p.addr = '123 Streets Way'
    p.city = 'Somewhere Ville'
    p.province = 'Ontario'
    p.postal_code = 'Z9Z 9Z9'
    p.contact.name = 'Contact Person'
    p.contact.email = 'test@example.com'
    p.contact.url = 'test.example.com/contact'

    ocds = p.ToProcuringEntityOCDS
    assert_not ocds[:id].blank?
    assert_not ocds.has_key?(:address)
    assert_not ocds.has_key?(:roles)
    assert_equal ocds[:name], 'Test Entity'
    assert_equal ocds[:name_fr], 'Entité de test'
    assert_equal ocds[:contactPoint][:name], 'Contact Person'
    assert_equal ocds[:contactPoint][:email], 'test@example.com'
    assert_equal ocds[:contactPoint][:url], 'test.example.com/contact'
  end

  test 'ProcuringEntity::ToProcuringEntityOCDS skips blank fields' do
    p = Converter::ProcuringEntity.new

    ocds = p.ToProcuringEntityOCDS
    assert_not ocds[:id].blank?
    assert_not ocds.has_key?(:roles)
    assert_not ocds.has_key?(:name)
    assert_not ocds.has_key?(:name_fr)
    assert_not ocds.has_key?(:address)
    assert_not ocds.has_key?(:contactPoint)
  end

  test 'ProcuringEntity::has_data? when empty' do
    p = Converter::ProcuringEntity.new
    assert_not p.has_data?
  end

  [:name_en, :name_fr, :addr, :city, :province, :postal_code].each do |val|
    test "ProcuringEntity::has_data? with #{val}" do
      p = Converter::ProcuringEntity.new
      p.send("#{val}=", "test value")
      assert p.has_data?
    end
  end

  test 'ProcuringEntity::has_data? with contact' do
    p = Converter::ProcuringEntity.new
    p.contact.name = "Test Contact"
    assert p.has_data?
  end
end

