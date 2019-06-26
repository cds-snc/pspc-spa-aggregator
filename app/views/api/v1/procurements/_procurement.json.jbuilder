json.ocid procurement.ocid
json.initiationType 'tender'
json.language 'en'

json.tender do
  json.partial! "api/v1/procurements/tender", tender: procurement
end
