json.id party.identifier
json.role ['procuringEntity']
json.name party.name_en unless party.name_en.blank?
json.name_fr party.name_fr unless party.name_fr.blank?

if !party.street_address.blank? || !party.city.blank? ||
    !party.province.blank? || !party.postal_code.blank?
  json.address do
    json.streetAddress party.street_address unless party.street_address.blank?
    json.locality party.city unless party.city.blank?
    json.region party.province unless party.province.blank?
    json.postalCode party.postal_code unless party.postal_code.blank?
  end
end
