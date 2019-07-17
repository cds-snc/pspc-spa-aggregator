json.ocid procurement.ocid
json.initiationType 'tender'
json.language 'en'

json.parties do
  json.array! [procurement.procuring_entity],
      partial: 'api/v1/procurements/party', as: :party
end

json.tender do
  json.partial! "api/v1/procurements/tender", tender: procurement
end
