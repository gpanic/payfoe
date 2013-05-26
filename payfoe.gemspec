Gem::Specification.new do |s|
  s.name        = 'payfoe'
  s.version     = '1.0.0'
  s.date        = '2013-08-06'
  s.summary     = "Not PayPal."
  s.description = "Simple online money transfer app"
  s.authors     = ["Gregor Panic"]
  s.email       = 'gregor.panic@gmail.com'
  s.files       = Dir['lib/*.rb']
  s.files       += Dir['lib/entities/*.rb']
  s.files       += Dir['lib/mappers/*.rb']
  s.files       += Dir['db/payfoe_schema.yaml']
  s.add_runtime_dependency 'sqlite3'
end
