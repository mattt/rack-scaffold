require "spec_helper"

describe Rack::Scaffold::Adapters::CoreData do
  let(:app) { Rack::Scaffold.new(model: "./example/Example.xcdatamodeld") }
  let(:adapter) { app.instance_variable_get("@adapter") }

  describe "Artist" do
    describe "collection" do
      subject(:artists) { adapter::Artist.all }

      it "is empty" do
        is_expected.to be_empty
      end

      it "has an empty representation" do
        get '/artists'
        expect(last_response.status).to eq(200)
        expect(last_response.body).to eq({artists: []}.to_json)
      end
    end

    describe "record" do
      let(:attributes) {
        {
          name: "Serge Gainsbourg",
          artistDescription: "Renowned for his often provocative and scandalous releases"
        }
      }

      before { post '/artists', attributes }
      subject(:artist) { adapter::Artist.first }

      it do
        expect(last_response.status).to eq(201)
        expect(last_response.body).to eq({artist: artist}.to_json)
      end

      it "is not nil" do
        is_expected.not_to be_nil
      end

      it "has attributes in response body" do
        expect(last_response.body).to eq({artist: artist}.to_json)
      end

      it "has the correct attributes" do
        expect(artist.name).to eq(attributes[:name])
        expect(artist.artistDescription).to eq(attributes[:artistDescription])
      end

      it "is listed with GET request" do
        get '/artists'
        expect(last_response.body).to eq({artists: [artist]}.to_json)
      end

      it "is shown with GET request" do
        get '/artists/1'
        expect(last_response.status).to eq(200)
        expect(last_response.body).to eq({artist: artist}.to_json)
      end

      it "is updated with PUT request" do
        name =  "Lucien"
        put '/artists/1', name: name
        expect(last_response.status).to eq(200)
        expect(adapter::Artist.first.name).to eq(name)
      end

      it "is updated with PATCH request" do
        name =  "Lucien"
        patch '/artists/1', name: name
        expect(last_response.status).to eq(200)
        expect(adapter::Artist.first.name).to eq(name)
      end

      it "is deleted with DELETE request" do
        delete "/artists/#{artist.id}"
        expect(last_response.status).to eq(204)
        expect(adapter::Artist.first(name: artist.name)).to be_nil
      end
    end
  end

  describe "Song" do
    describe "collection" do
      subject(:songs) { adapter::Song.all }

      it "is empty" do
        is_expected.to be_empty
      end

      it "has an empty representation" do
        get '/songs'
        expect(last_response.status).to eq(200)
        expect(last_response.body).to eq({songs: []}.to_json)
      end
    end

    describe "record" do
      let(:artist) { adapter::Artist.create() }

      let(:attributes) {
        {
          title: "Black Trombone",
          artist_id: artist.id
        }
      }

      before { post '/songs', attributes }
      subject(:song) { adapter::Song.first }

      it do
        expect(last_response.status).to eq(201)
        expect(last_response.body).to eq({song: song}.to_json)
      end

      it "is listed with GET" do
        get "/artists/#{artist.id}/songs"
        expect(last_response.status).to eq(200)
        expect(last_response.body).to eq({songs: [song]}.to_json)
      end

      it "is shown with GET request" do
        get "/songs/#{song.id}"
        expect(last_response.status).to eq(200)
        expect(last_response.body).to eq({song: song}.to_json)
      end

      it "is updated with PUT request" do
        title = "Je T'Aime....Moi Non Plus"
        put "/songs/#{song.id}", title: title
        expect(last_response.status).to eq(200)
        expect(adapter::Song.first.title).to eq(title)
      end

      it "is updated with PATCH request" do
        title = "Je T'Aime....Moi Non Plus"
        patch "/songs/#{song.id}", title: title
        expect(last_response.status).to eq(200)
        expect(adapter::Song.first.title).to eq(title)
      end

      it "is deleted with DELETE request" do
        delete "/songs/#{song.id}"
        expect(last_response.status).to eq(204)
        expect(adapter::Song.first(title: song.title)).to be_nil
      end
    end
  end
end
