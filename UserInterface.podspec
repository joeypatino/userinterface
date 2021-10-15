Pod::Spec.new do |s|
    s.name         = 'UserInterface'
    s.version      = '0.1.1'
    s.summary      = 'A collection of user interface elements for iOS'
    s.homepage     = 'https://www.github.com/joeypatino/userinterface'
    s.description  = <<-DESC
    UserInterface is a collection iOS User interface elements and extensions, written in Swift.
    DESC
    s.license = { :type => 'MIT', :file => 'LICENSE.md' }

    s.author       = { 'joey patino' => 'joey.patino@protonmail.com' }
    s.source       = { :git => 'https://www.github.com/joeypatino/userinterface.git', :tag => s.version.to_s }

    s.source_files  = 'UserInterface/Classes/**/*.swift'
    
    s.platform = :ios
    s.swift_version = '5.0'
    s.ios.deployment_target  = '12.1'
end
