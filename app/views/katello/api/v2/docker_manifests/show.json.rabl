object @resource

attributes :id, :schema_version, :digest, :manifest_type

child :docker_tags => :tags do
  attributes :associated_meta_tag_identifier => :id
  attributes :repository_id, :name
end

child :docker_manifest_lists => :manifest_lists do
  attributes :id, :digest, :schema_version, :manifest_type
end
