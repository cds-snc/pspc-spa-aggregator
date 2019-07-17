json.publisher do
  json.name "SPA"
end

json.license "http://open.canada.ca/en/open-government-licence-canada"
json.license_fr "http://ouvert.canada.ca/fr/licence-du-gouvernement-ouvert-canada"

json.extensions do
  json.array! %w(
    https://github.com/open-contracting-extensions/ocds_options_extension
    https://github.com/open-contracting-extensions/ocds_recurrence_extension
    https://github.com/open-contracting-extensions/ocds_additionalContactPoints_extension
    https://github.com/open-contracting-extensions/ocds_coveredBy_extension
    https://github.com/open-contracting-extensions/ocds_procurementMethodModalities_extension
 )
end

json.releases do
  json.array! procurements,
      partial: "api/v1/procurements/procurement",
      as: :procurement
end

