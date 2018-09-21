json.extract! profile, :id, :name, :email, :created_at, :updated_at
json.url profile_url(profile, format: :json)
