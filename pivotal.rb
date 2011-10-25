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
Project: #{project_name_from_bug(bug)}
File: #{bug["file"]}
Line number: #{bug["line_number"]}
Controller: #{bug["controller"]}
Action: #{bug["action"]}
Environment: #{bug["rails_env"]}

#{bug["error_message"]}
EOF

        xml.external_story do
          xml.external_id bug["id"]
          xml.name bug["error_class"]
          xml.description description
          xml.requested_by requestor
          xml.created_at({ :type => "datetime" }, bug["updated_at"])
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

  def project_name_from_bug(bug)
    project_id = bug['project_id'].to_i

    case project_id
    when 16134
      '635 Secure Parking'
    when 19627
      'Breastcancer.org Community'
    when 47801
      'Bull Publishing'
    when 20737
      'Cancer and Careers'
    when 42945
      'eLapse'
    when 16034
      'Interport'
    when 20838
      'NICA Pitzone'
    else
      'Unknown'
    end
  end

end