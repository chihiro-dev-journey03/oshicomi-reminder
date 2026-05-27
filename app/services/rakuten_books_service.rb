class RakutenBooksService
  API_URL = "https://openapi.rakuten.co.jp/services/api/BooksBook/Search/20170404"
  MAX_RESULTS = 10

  def self.search(keyword)
    uri = URI(API_URL)
    uri.query = URI.encode_www_form(
      applicationId: ENV["RAKUTEN_APP_ID"],
      accessKey: ENV["RAKUTEN_ACCESS_KEY"],
      title: keyword,
      formatVersion: 2,
      hits: MAX_RESULTS
    )

    response = Net::HTTP.get_response(uri)
    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.error("Rakuten API response body: #{response.body}")
      raise "Rakuten API error: #{response.code}"
    end

    data = JSON.parse(response.body)
    format_results(data["Items"] || [])
  rescue StandardError => e
    Rails.logger.error("RakutenBooksService error: #{e.message}")
    []
  end

  def self.format_results(items)
    items.map do |item|
      {
        title: item["title"],
        author: item["author"],
        image_url: item["mediumImageUrl"]
      }
    end
  end
  private_class_method :format_results
end
