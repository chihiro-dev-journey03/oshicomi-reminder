class RakutenBooksService
  API_URL = "https://openapi.rakuten.co.jp/services/api/BooksBook/Search/20170404"
  MAX_RESULTS = 10
  ENRICH_MAX_RESULTS = 30

  def self.search(keyword, hits: MAX_RESULTS)
    uri = URI(API_URL)
    uri.query = URI.encode_www_form(
      applicationId: ENV["RAKUTEN_APP_ID"],
      accessKey: ENV["RAKUTEN_ACCESS_KEY"],
      title: keyword,
      formatVersion: 2,
      hits: hits
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
        image_url: item["largeImageUrl"].presence || item["mediumImageUrl"]
      }
    end
  end

  # ベースタイトルから楽天APIを検索し、1巻の書影・著者情報を返す
  def self.find_volume_one(base_title)
    keyword = base_title.to_s.strip
    return nil if keyword.blank?

    results = search_results_for_base_title(keyword)
    pick_volume_one(results, keyword)
  end

  def self.search_results_for_base_title(keyword)
    seen_titles = {}
    merged = []

    [ keyword, "#{keyword} 1", "#{keyword} 1巻" ].each do |query|
      search(query, hits: ENRICH_MAX_RESULTS).each do |item|
        next if seen_titles[item[:title]]

        seen_titles[item[:title]] = true
        merged << item
      end
    end

    merged
  end

  def self.extract_base_title(title)
    title.to_s.unicode_normalize(:nfc)
      .gsub(/^【[^】]*】\s*/, "")
      .gsub(/\u3000.*$/, "")
      .gsub(/\s+[#＃]\d.*$/, "")
      .gsub(/\s+\d+.*$/, "")
      .gsub(/（[\d上中下巻]+）$/, "")
      .strip
  end

  def self.pick_volume_one(results, base_title)
    return nil if results.blank?

    base_key = normalize_key(base_title)
    matching = results.select { |r| normalize_key(extract_base_title(r[:title])) == base_key }

    volume_ones = matching.select { |r| volume_one_title?(r[:title]) }
    return volume_ones.min_by { |r| r[:title].length } if volume_ones.any?

    # 1巻がAPI結果に無い場合は単行本のうち巻数が最小のもの（全巻セットは除外）
    singles = matching.reject { |r| bundle_title?(r[:title]) }
    singles
      .select { |r| extract_volume_number(r[:title]) }
      .min_by { |r| extract_volume_number(r[:title]) }
  end

  def self.extract_volume_number(title)
    return nil if bundle_title?(title)

    normalized = title.unicode_normalize(:nfc)
    match = normalized.match(/(?:^|[\s　])(\d+)(?:巻)?(?:\s|$|（)/)
    match ? match[1].to_i : nil
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

  private_class_method :format_results, :search_results_for_base_title, :pick_volume_one,
                        :extract_base_title, :extract_volume_number,
                        :volume_one_title?, :bundle_title?, :other_volume_title?, :normalize_key
end
