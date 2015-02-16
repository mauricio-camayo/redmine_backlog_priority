
module Hooks
  class ControllerIssuesEditAfterSaveHook < Redmine::Hook::ViewListener

    def controller_issues_edit_after_save(context={})
      if Setting.plugin_redmine_backlog_priority.has_key?("custom_field_name") and Setting.plugin_redmine_backlog_priority.has_key?("target_version")
        current_priority = 0
        
        current_issue = Issue.find(context[:params][:id])
        if current_issue.status.is_closed
          return ''
        end
        if current_issue[:fixed_version_id] != Setting.plugin_redmine_backlog_priority['target_version'].at(0).to_i
          return ''
        end
        puts current_issue.inspect
        puts current_issue[:fixed_version_id].inspect
        
        context[:params][:issue][:custom_field_values].each do |c|
          if c.at(0) == Setting.plugin_redmine_backlog_priority['custom_field_name'].at(0)
            current_priority = c.at(1).to_i
          end
        end
        query = " select issues.id, custom_values.value " +
                  " from issues, issue_statuses, custom_values " +
                  " where issues.id = custom_values.customized_id " +
                  " and issues.id <> " + context[:params][:id] +
                  " and issues.status_id = issue_statuses.id " +
                  " and issue_statuses.is_closed <> 1  " +
                  " and issues.fixed_version_id = " + Setting.plugin_redmine_backlog_priority['target_version'].at(0) +
                  " and custom_values.custom_field_id = " + Setting.plugin_redmine_backlog_priority['custom_field_name'].at(0) +
                  " and custom_values.value >= " + current_priority.to_s +
                  " order by custom_values.value "
#        puts query
        Issue.connection.select_all( query ).each do |i|
          if i["value"].to_i == current_priority
            mod_issue = Issue.find(i["id"])
            mod_issue.custom_field_values.each do |c|
              if c.custom_field.id == Setting.plugin_redmine_backlog_priority['custom_field_name'].at(0).to_i
                current_priority += 1
                c.value = current_priority.to_s
              end
            end
            mod_issue.save
          end
        end
        
      end
      return ''
    end
  end
end
