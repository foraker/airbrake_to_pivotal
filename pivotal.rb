require "builder"

class Pivotal

  attr_reader :requestor

  def initialize(requestor, production_errors_only = false)
    @requestor, @production_errors_only = requestor, production_errors_only
  end

  def bugs_to_xml(bugs)
    buffer = ""

    xml = Builder::XmlMarkup.new(:target => buffer, :indent => 2)

    xml.instruct!

    xml.external_stories(:type => "array") do
      bugs.each do |bug|
        next if should_skip?(bug)

        description = <<-EOF
File: #{bug["file"]}
Line number: #{bug["line_number"]}
Controller: #{bug["controller"]}
Action: #{bug["action"]}
Environment: #{bug["rails_env"]}
Error setting: #{production_errors_only?.to_s}

#{bug["error_message"]}
EOF

        xml.external_story do
          xml.external_id bug["id"]
          xml.name bug["error_class"]
          xml.description description
          xml.requested_by requestor
          xml.created_at({ :type => "datetime" }, bug["created_at"])
          xml.story_type "bug"
          xml.estimate nil
        end
      end
    end

    buffer
  end

  private

  def should_skip?(bug)
    return true if production_errors_only? && bug["rails_env"] != 'production'
    return false
  end

  def production_errors_only?
    @production_errors_only
  end

end