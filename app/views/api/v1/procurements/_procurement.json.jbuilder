json.ocid procurement.ocid
json.initiationType 'tender'
json.language 'en'

if !procurement.procuring_entity.nil?
  json.parties do
    json.array! [procurement.procuring_entity],
        partial: 'api/v1/procurements/party', as: :party
  end
end

json.tender do
  json.partial! "api/v1/procurements/tender", tender: procurement
end
