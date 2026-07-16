require 'rails_helper'

RSpec.describe RakutenBooksService do
  describe ".search" do
    context "環境変数が未設定の場合" do
      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("RAKUTEN_APP_ID").and_return(nil)
        allow(ENV).to receive(:[]).with("RAKUTEN_ACCESS_KEY").and_return(nil)
      end

      it "空配列を返す" do
        expect(described_class.search("進撃の巨人")).to eq([])
      end
    end

    context "APIが正常に応答する場合" do
      let(:api_response) do
        {
          "Items" => [
            {
              "title" => "進撃の巨人 1",
              "author" => "諫山創",
              "largeImageUrl" => "https://example.com/large.jpg",
              "mediumImageUrl" => "https://example.com/medium.jpg"
            }
          ]
        }.to_json
      end

      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("RAKUTEN_APP_ID").and_return("dummy_app_id")
        allow(ENV).to receive(:[]).with("RAKUTEN_ACCESS_KEY").and_return("dummy_key")

        response_double = instance_double(Net::HTTPSuccess, body: api_response)
        allow(response_double).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
        allow(Net::HTTP).to receive(:get_response).and_return(response_double)
      end

      it "タイトル・著者・画像URLを含む配列を返す" do
        result = described_class.search("進撃の巨人")
        expect(result.first).to include(
          title: "進撃の巨人 1",
          author: "諫山創",
          image_url: "https://example.com/large.jpg"
        )
      end
    end

    context "APIがエラーを返す場合" do
      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("RAKUTEN_APP_ID").and_return("dummy_app_id")
        allow(ENV).to receive(:[]).with("RAKUTEN_ACCESS_KEY").and_return("dummy_key")

        response_double = instance_double(Net::HTTPServerError, body: "Internal Server Error", code: "500")
        allow(response_double).to receive(:is_a?).with(Net::HTTPSuccess).and_return(false)
        allow(Net::HTTP).to receive(:get_response).and_return(response_double)
      end

      it "空配列を返す" do
        expect(described_class.search("進撃の巨人")).to eq([])
      end
    end

    context "ネットワークエラーが発生した場合" do
      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("RAKUTEN_APP_ID").and_return("dummy_app_id")
        allow(ENV).to receive(:[]).with("RAKUTEN_ACCESS_KEY").and_return("dummy_key")
        allow(Net::HTTP).to receive(:get_response).and_raise(StandardError, "connection failed")
      end

      it "空配列を返す" do
        expect(described_class.search("進撃の巨人")).to eq([])
      end
    end
  end
end
