Pod::Spec.new do |s|
  s.name         = "KISlideController"
  s.version      = "0.1"
  s.summary      = "KISlideController"
  s.description  = <<-DESC
					  KISlideController.
                   DESC

  s.homepage     = "https://github.com/smartwalle/KISlideController"
  s.license      = "MIT"

  s.author       = { "SmartWalle" => "smartwalle@gmail.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/smartwalle/KISlideController.git", :branch => "master" }
  s.source_files  = "KISlideController/KISlideController/*.{h,m}"
  s.exclude_files = "Classes/Exclude"
  s.requires_arc = true
end
