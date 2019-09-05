json.id item.identifier
json.description item.description_en unless item.description_en.blank?
json.description_fr item.description_fr unless item.description_fr.blank?
json.quantity item.quantity unless item.quantity.blank?
json.units item.units_en unless item.units_en.blank?
json.units_fr item.units_fr unless item.units_fr.blank?
