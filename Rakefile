require "erb"

# @ripienaar https://www.devco.net/archives/2010/11/18/a_few_rake_tips.php
def render_template(template, output, scope)
  tmpl = File.read(template)
  erb = ERB.new(tmpl, 0, "<>")
  File.open(output, "w") do |f|
    f.puts erb.result(scope)
  end
end

maintainer = 'jesse_weisner@bcit.ca'
org_name = ENV['PRIVATE_REGISTRY_ORG']
image_name = 'openshift-spectrumprotect'
registry = ENV['PRIVATE_REGISTRY']
version = '7.1.8.0'
version_segments = version.split('.')
tarball = "#{version}-TIV-TSMBAC-LinuxX86.tar"
download_url = "ftp://public.dhe.ibm.com/storage/tivoli-storage-management/maintenance/client/v#{version_segments[0]}r#{version_segments[1]}/Linux/LinuxX86/BA/v#{version_segments[0..2].join}/#{tarball}"
tags = [
  "#{version_segments[0]}.#{version_segments[1]}",
  "#{version_segments[0]}.#{version_segments[1]}.#{version_segments[2]}",
  'latest'
]

desc "Template, build, tag, push"
task :default do
  Rake::Task[:Dockerfile].invoke
  Rake::Task[:build].invoke
  Rake::Task[:test].invoke
  Rake::Task[:tag].invoke
  Rake::Task[:push].invoke
end

desc "Update Dockerfile templates"
task :Dockerfile do
  render_template("Dockerfile.erb", "Dockerfile", binding)
end

desc "Build docker images"
task :build do
  sh "curl -O #{download_url}" unless File.exist?(tarball)
  Dir.mkdir("rpms") unless Dir.exists?("rpms")
  Dir.chdir("rpms") do
    sh "tar xf ../#{tarball}"
  end
  sh "docker build -t #{registry}/#{org_name}/#{image_name}:#{version} ."
end

desc "Test docker images"
task :test do
  puts "Running tests on #{registry}/#{org_name}/#{image_name}:#{version}"
  puts "lol"
end

desc "Tag docker images"
task :tag do
  tags.each do |tag|
    sh "docker tag #{registry}/#{org_name}/#{image_name}:#{version} #{registry}/#{org_name}/#{image_name}:#{tag}"
  end
end

desc "Push to Private Registry"
task :push do
  sh "docker push #{registry}/#{org_name}/#{image_name}:#{version}"

  tags.each do |tag|
    sh "docker push #{registry}/#{org_name}/#{image_name}:#{tag}"
  end
end

desc "OpenShift login"
task :oc_login do
  sh "oc project" do | success, exit_code |
    sh "oc login" unless success
  end
end

desc "Openshift task cleanup"
task :oc_cleanup do
  Rake::Task[:oc_login].invoke
  sh "oc delete deploymentconfig backup --ignore-not-found --wait"
end

desc "Configure backup service account"
task :serviceaccount do
  Rake::Task[:oc_login].invoke
  sh "oc get serviceaccount backup" do | success, exit_code |
    sh "oc create serviceaccount backup" unless success
  end

  sh "oc adm policy add-role-to-user admin -z backup"
end

desc "Run backup in current project"
task :backup do
  Rake::Task[:oc_login].invoke
  Rake::Task[:oc_cleanup].invoke
  #sh "oc oc run backup --image=#{registry}/#{org_name}/#{image_name}:#{version} "
end
