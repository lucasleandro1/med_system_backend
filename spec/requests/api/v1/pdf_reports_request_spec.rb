# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PdfReports" do
  describe "GET api/v1/pdf_reports/generate" do
    context "when entity_name is missing" do
      it "returns a bad request error" do
        user = create(:user)
        headers = auth_token_for(user)
        get api_v1_pdf_reports_generate_path, headers: headers

        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body["error"]).to eq("You must inform the `entity_name` parameter")
      end
    end

    context "when entity_name is 'event_procedures'" do
      before do
        user = create(:user)
        headers = auth_token_for(user)
        entity_name = "event_procedures"
        get api_v1_pdf_reports_generate_path, params: { entity_name: entity_name }, headers: headers
      end

      it "returns a PDF file" do
        expect(response.content_type).to eq("application/pdf")
        expect(response.headers["Content-Disposition"]).to include("inline")
        expect(response.body).not_to be_empty
      end

      it "includes correct filename" do
        expect(response.headers["Content-Disposition"]).to include(
          "filename=\"#{Time.zone.now.strftime('%d%m%Y')}_report.pdf\""
        )
      end
    end

    context "when entity_name is 'medical_shifts'" do
      before do
        user = create(:user)
        headers = auth_token_for(user)
        entity_name = "medical_shifts"
        get api_v1_pdf_reports_generate_path, params: { entity_name: entity_name }, headers: headers
      end

      it "returns a PDF file" do
        expect(response.content_type).to eq("application/pdf")
        expect(response.headers["Content-Disposition"]).to include("inline")
        expect(response.body).not_to be_empty
      end

      it "includes correct filename" do
        expect(response.headers["Content-Disposition"]).to include(
          "filename=\"#{Time.zone.now.strftime('%d%m%Y')}_report.pdf\""
        )
      end
    end
  end
end
