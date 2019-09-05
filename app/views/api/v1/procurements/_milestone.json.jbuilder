json.type milestone[:type]
json.dueDate milestone[:due_date] unless milestone[:due_date].blank?
json.description milestone[:description_en] unless milestone[:description_en].blank?
json.description_fr milestone[:description_fr] unless milestone[:description_fr].blank?
