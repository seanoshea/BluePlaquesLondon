Pod::Spec.new do |s|
  s.name         = "TBXML"
  s.version      = "1.5"
  s.summary      = "TBXML is a light-weight XML document parser written in Objective-C."
  s.homepage     = "http://www.tbxml.co.uk/"
  s.license      = { :type => 'MIT', :file => 'README.markdown' }
  s.author       = { "Tom Bradley" => "tom@71squared.com" }
  s.source       = { :path => "." }
  s.platform     = :ios, '8.0'
  s.source_files = 'TBXML-Code/*.{h,m}', 'TBXML-Headers/*.h'
  s.public_header_files = 'TBXML-Headers/*.h'
  s.requires_arc = false
end