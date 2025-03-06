require 'rails_helper'

RSpec.describe HealthController, type: :controller do
  describe "GET #show" do
    before do
      allow(Redis.current).to receive(:ping).and_return("PONG")
    end

    it "returns http success" do
      get :show
      expect(response).to have_http_status(:success)
    end

    it "returns health status in JSON format" do
      get :show
      json_response = JSON.parse(response.body)
      
      expect(json_response).to include(
        "status" => "ok",
        "database" => true,
        "redis" => true
      )
      expect(json_response["timestamp"]).to be_present
    end

    context "when Redis is down" do
      before do
        allow(Redis.current).to receive(:ping).and_raise(Redis::CannotConnectError)
      end

      it "returns Redis status as false" do
        get :show
        json_response = JSON.parse(response.body)
        
        expect(json_response["redis"]).to be false
        expect(json_response["status"]).to eq "ok"
        expect(json_response["database"]).to be true
      end
    end

    context "when database is down" do
      before do
        allow(ActiveRecord::Base.connection).to receive(:active?).and_raise(ActiveRecord::ConnectionNotEstablished)
      end

      it "returns database status as false" do
        get :show
        json_response = JSON.parse(response.body)
        
        expect(json_response["database"]).to be false
        expect(json_response["status"]).to eq "ok"
        expect(json_response["redis"]).to be true
      end
    end
  end
end
