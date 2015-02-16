Redmine::Plugin.register :redmine_backlog_priority do
  name 'Redmine Backlog Priority plugin'
  author 'Mauricio Camayo'
  description 'We use a custom field to set the priority on for a target version. This plugin reviews that there are not duplicated priorities'
  version '0.0.1'
  url 'https://github.com/mauricio-camayo/redmine_backlog_priority'
  author_url 'https://github.com/mauricio-camayo'
  
  settings :default => {'empty' => true}, :partial => 'settings/backlog_priority_settings'
  
  require_dependency 'hooks/controller_issues_edit_after_save_hook.rb'
end
