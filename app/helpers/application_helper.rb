module ApplicationHelper
  def status_badge_class(status)
    base = "inline-block text-xs font-medium px-2.5 py-1 rounded-full"
    case status
    when "pending" then "#{base} bg-blue-100 text-blue-700"
    when "sent"    then "#{base} bg-green-100 text-green-700"
    when "failed"  then "#{base} bg-red-100 text-red-700"
    else                "#{base} bg-gray-100 text-gray-600"
    end
  end
end
