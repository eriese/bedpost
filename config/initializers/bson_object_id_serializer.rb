#serialize BSON:ObjectIds as just their string Ids
module BSON
	class ObjectId
		def as_json(*)
			to_s.as_json
		end
	end
end
