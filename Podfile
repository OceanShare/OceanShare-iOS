# Uncomment the next line to define a global platform for your project
# platform :ios, '12.1'

# inhibit_all_warnings!

target 'OceanShare' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for OceanShare
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Database'
  pod 'Firebase/Storage'
  pod 'Mapbox-iOS-SDK'
  pod 'GoogleSignIn'
  pod 'FBSDKCoreKit', '4.36.0', :inhibit_warnings => true
  pod 'FBSDKShareKit', '4.36.0', :inhibit_warnings => true
  pod 'FBSDKLoginKit', '4.36.0', :inhibit_warnings => true
  pod 'FacebookCore', '0.4', :inhibit_warnings => true
  pod 'FacebookLogin', '0.4', :inhibit_warnings => true
  pod 'TwitterKit'
  pod 'Alamofire', '~> 5.0.0.beta.1'
  pod 'JJFloatingActionButton'
  pod 'SkeletonView'
  pod 'Firebase/Analytics'
  pod 'Firebase/Performance'
  pod 'Fabric', '~> 1.10.1'
  pod 'Crashlytics', '~> 3.13.1'
  pod 'SwiftyJSON', '~> 4.0'

  target 'OceanShareTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'Firebase/Core'
  end

  target 'OceanShareUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

PROJECT_ROOT_DIR = File.dirname(File.expand_path(__FILE__))
PODS_DIR = File.join(PROJECT_ROOT_DIR, 'Pods')
PODS_TARGET_SUPPORT_FILES_DIR = File.join(PODS_DIR, 'Target Support Files')

post_install do |installer|
  remove_static_framework_duplicate_linkage({'SharedFramework' => ['TwitterCore']})
end

def remove_static_framework_duplicate_linkage(static_framework_pods)
  puts "Removing duplicate linkage of static frameworks"
  
  Dir.glob(File.join(PODS_TARGET_SUPPORT_FILES_DIR, "Pods-*")).each do |path|
    pod_target = path.split('-', -1).last
    
    static_framework_pods.each do |target, pods|
      next if pod_target == target
      frameworks = pods.map { |pod| identify_frameworks(pod) }.flatten
      
      Dir.glob(File.join(path, "*.xcconfig")).each do |xcconfig|
        lines = File.readlines(xcconfig)
        
        if other_ldflags_index = lines.find_index { |l| l.start_with?('OTHER_LDFLAGS') }
          other_ldflags = lines[other_ldflags_index]
          
          frameworks.each do |framework|
            other_ldflags.gsub!("-framework \"#{framework}\"", '')
          end
          
          File.open(xcconfig, 'w') do |fd|
            fd.write(lines.join)
          end
        end
      end
    end
  end
end

def identify_frameworks(pod)
  frameworks = Dir.glob(File.join(PODS_DIR, pod, "**/*.framework")).map { |path| File.basename(path) }
  
  if frameworks.any?
    return frameworks.map { |f| f.split('.framework').first }
  end
  
  return pod
end
