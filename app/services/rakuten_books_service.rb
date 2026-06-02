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

  # ベースタイトルから楽天APIを検索し、1巻の書影・著者情報を返す
  def self.find_volume_one(base_title)
    keyword = base_title.to_s.strip
    return nil if keyword.blank?

    results = search("#{keyword} 1")
    results = search(keyword) if results.empty?

    pick_volume_one(results, keyword)
  end

  def self.pick_volume_one(results, base_title)
    return nil if results.blank?

    base_key = normalize_key(base_title)

    volume_ones = results.select do |r|
      normalize_key(r[:title]).start_with?(base_key) && volume_one_title?(r[:title])
    end

    chosen = volume_ones.min_by { |r| r[:title].length }
    return chosen if chosen

    # 1巻らしきものがなければセット・他巻を除いた最短タイトル
    results
      .reject { |r| bundle_title?(r[:title]) || other_volume_title?(r[:title]) }
      .select { |r| normalize_key(r[:title]).start_with?(base_key) }
      .min_by { |r| r[:title].length }
  end

  def self.other_volume_title?(title)
    return false if volume_one_title?(title)

    title.unicode_normalize(:nfc).match?(/(?:^|[\s　])(?:[2-9]\d*|1[0-9]+)(?:巻)?(?:\s|$|（)/)
  end

  def self.volume_one_title?(title)
    return false if bundle_title?(title)

    normalized = title.unicode_normalize(:nfc)

    return true if normalized.match?(/(?:^|[\s　])1(?:巻)?(?:\s|$|（)/)
    return true if normalized.match?(/（1）\s*$/)
    return true if normalized.match?(/１(?:巻)?(?:\s|$)/)

    false
  end

  def self.bundle_title?(title)
    normalized = title.unicode_normalize(:nfc)

    normalized.match?(/全巻|セット|完結|盒|BOX/i) ||
      normalized.match?(/1[〜～\-－]\d/) ||
      normalized.match?(/\d+-\d+巻/) ||
      normalized.match?(/上中下|全\d+巻/)
  end

  def self.normalize_key(str)
    str.unicode_normalize(:nfc).gsub(/[\s\u3000]/, "").downcase
  end

  private_class_method :format_results, :pick_volume_one, :volume_one_title?, :bundle_title?, :other_volume_title?, :normalize_key
end
