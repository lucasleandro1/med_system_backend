# frozen_string_literal: true

require "rails_helper"

RSpec.describe "EventProcedures" do
  describe "GET /api/v1/event_procedures" do
    context "when user is not authenticated" do
      it "returns unauthorized" do
        get "/api/v1/event_procedures", params: {}, headers: {}

        expect(response).to have_http_status(:unauthorized)
      end

      it "returns error message" do
        get "/api/v1/event_procedures"

        expect(response.parsed_body["error_description"]).to eq(["Invalid token"])
      end
    end

    context "when user is authenticated" do
      let!(:user) { create(:user) }

      before do
        create_list(:event_procedure, 5, user_id: user.id)
        headers = auth_token_for(user)
        get("/api/v1/event_procedures", params: {}, headers: headers)
      end

      it "returns ok" do
        expect(response).to have_http_status(:ok)
      end

      it "returns all event_procedures" do
        expect(response.parsed_body["event_procedures"].length).to eq(5)
      end
    end

    context "when has filters by month" do
      let!(:user) { create(:user) }

      it "returns event_procedures per month" do
        headers = auth_token_for(user)
        create_list(:event_procedure, 3, date: "2023-02-15", user_id: user.id)
        _month_5_event_procedure = create_list(:event_procedure, 5, date: "2023-05-26", user_id: user.id)

        get("/api/v1/event_procedures", params: { month: "2" }, headers: headers)

        expect(response.parsed_body["event_procedures"].length).to eq(3)
      end
    end

    context "when filtering by payd" do
      context "when payd is 'true'" do
        let!(:user) { create(:user) }

        it "returns only paid event_procedures" do
          headers = auth_token_for(user)
          create_list(:event_procedure, 3, payd: true, user_id: user.id)
          _unpayd_event_procedures = create_list(:event_procedure, 5, payd: false, user_id: user.id)

          get("/api/v1/event_procedures", params: { payd: "true" }, headers: headers)

          expect(response.parsed_body["event_procedures"].length).to eq(3)
        end
      end

      context "when payd is 'false'" do
        let!(:user) { create(:user) }

        it "returns only unpaid event_procedures" do
          headers = auth_token_for(user)
          create_list(:event_procedure, 3, payd: true, user_id: user.id)
          _unpayd_event_procedures = create_list(:event_procedure, 5, payd: false, user_id: user.id)

          get("/api/v1/event_procedures", params: { payd: "false" }, headers: headers)

          expect(response.parsed_body["event_procedures"].length).to eq(5)
        end
      end
    end

    context "when has pagination via page and per_page" do
      let!(:user) { create(:user) }

      before do
        headers = auth_token_for(user)
        create_list(:event_procedure, 8, user_id: user.id)
        get "/api/v1/event_procedures", params: { page: 2, per_page: 5 }, headers: headers
      end

      it "returns only 3 event_procedures" do
        expect(response.parsed_body["event_procedures"].length).to eq(3)
      end
    end
  end

  describe "POST /api/v1/event_procedures" do
    context "when user is authenticated" do
      context "with valid attributes" do
        context "when patient exists" do
          it "returns created" do
            user = create(:user)
            patient = create(:patient)
            procedure = create(:procedure)
            health_insurance = create(:health_insurance)
            params = {
              hospital_id: create(:hospital).id,
              health_insurance_id: create(:health_insurance).id,
              patient_service_number: "1234567890",
              date: Time.zone.now.to_date,
              urgency: false,
              room_type: EventProcedures::RoomTypes::WARD,
              payment: EventProcedures::Payments::HEALTH_INSURANCE,
              user_id: user.id,
              patient_attributes: { id: patient.id },
              procedure_attributes: { id: procedure.id },
              health_insurance_attributes: { id: health_insurance.id }
            }

            headers = auth_token_for(user)
            post "/api/v1/event_procedures", params: params, headers: headers

            expect(response).to have_http_status(:created)
          end

          it "returns event_procedure" do
            user = create(:user)
            patient = create(:patient)
            procedure = create(:procedure)
            health_insurance = create(:health_insurance)
            params = {
              hospital_id: create(:hospital).id,
              patient_service_number: "1234567890",
              date: Time.zone.now.to_date,
              urgency: false,
              room_type: EventProcedures::RoomTypes::WARD,
              payment: EventProcedures::Payments::HEALTH_INSURANCE,
              user_id: user.id,
              patient_attributes: { id: patient.id },
              procedure_attributes: { id: procedure.id },
              health_insurance_attributes: { id: health_insurance.id },
              payd: true
            }

            headers = auth_token_for(user)
            post "/api/v1/event_procedures", params: params, headers: headers

            expect(response.parsed_body).to include(
              "procedure" => EventProcedure.last.procedure.name,
              "patient" => patient.name,
              "hospital" => EventProcedure.last.hospital.name,
              "health_insurance" => EventProcedure.last.health_insurance.name,
              "patient_service_number" => params[:patient_service_number],
              "date" => params[:date].strftime("%d/%m/%Y"),
              "room_type" => EventProcedures::RoomTypes::WARD,
              "payment" => EventProcedures::Payments::HEALTH_INSURANCE,
              "urgency" => false,
              "payd" => true
            )
          end
        end

        context "when patient does not exist" do
          it "returns created" do
            user = create(:user)
            procedure = create(:procedure)
            health_insurance = create(:health_insurance)
            params = {
              procedure_id: create(:procedure).id,
              hospital_id: create(:hospital).id,
              health_insurance_id: create(:health_insurance).id,
              patient_service_number: "1234567890",
              date: Time.zone.now.to_date,
              urgency: false,
              room_type: EventProcedures::RoomTypes::WARD,
              payment: EventProcedures::Payments::HEALTH_INSURANCE,
              user_id: user.id,
              patient_attributes: { name: "patient 1" },
              procedure_attributes: { id: procedure.id },
              health_insurance_attributes: { id: health_insurance.id }
            }

            headers = auth_token_for(user)
            post "/api/v1/event_procedures", params: params, headers: headers

            expect(response).to have_http_status(:created)
          end

          it "returns event_procedure" do
            user = create(:user)
            procedure = create(:procedure)
            health_insurance = create(:health_insurance)
            params = {
              hospital_id: create(:hospital).id,
              patient_service_number: "1234567890",
              date: Time.zone.now.to_date,
              urgency: false,
              room_type: EventProcedures::RoomTypes::WARD,
              payment: EventProcedures::Payments::HEALTH_INSURANCE,
              user_id: user.id,
              patient_attributes: { name: "patient 1" },
              procedure_attributes: { id: procedure.id },
              health_insurance_attributes: { id: health_insurance.id }
            }

            headers = auth_token_for(user)
            post "/api/v1/event_procedures", params: params, headers: headers

            expect(response.parsed_body).to include(
              "procedure" => EventProcedure.last.procedure.name,
              "patient" => "patient 1",
              "hospital" => EventProcedure.last.hospital.name,
              "health_insurance" => EventProcedure.last.health_insurance.name,
              "patient_service_number" => params[:patient_service_number],
              "date" => params[:date].strftime("%d/%m/%Y"),
              "room_type" => EventProcedures::RoomTypes::WARD,
              "payment" => EventProcedures::Payments::HEALTH_INSURANCE,
              "urgency" => false
            )
          end
        end

        context "when procedure does not exist" do
          it "returns created" do
            user = create(:user)
            patient = create(:patient)
            health_insurance = create(:health_insurance)
            procedure_attributes = attributes_for(:procedure, custom: true)
            params = {
              hospital_id: create(:hospital).id,
              health_insurance_id: create(:health_insurance).id,
              patient_service_number: "1234567890",
              date: Time.zone.now.to_date,
              urgency: nil,
              room_type: nil,
              payment: EventProcedures::Payments::OTHERS,
              user_id: user.id,
              patient_attributes: { id: patient.id },
              procedure_attributes: procedure_attributes,
              health_insurance_attributes: { id: health_insurance.id }
            }

            headers = auth_token_for(user)
            post "/api/v1/event_procedures", params: params, headers: headers

            expect(response).to have_http_status(:created)
          end
        end

        context "when health_insurance does not exist" do
          it "returns created" do
            user = create(:user)
            patient = create(:patient)
            procedure = create(:procedure)
            health_insurance_attributes = attributes_for(:health_insurance, custom: true)
            params = {
              hospital_id: create(:hospital).id,
              health_insurance_id: create(:health_insurance).id,
              patient_service_number: "1234567890",
              date: Time.zone.now.to_date,
              urgency: nil,
              room_type: nil,
              payment: EventProcedures::Payments::OTHERS,
              user_id: user.id,
              patient_attributes: { id: patient.id },
              procedure_attributes: { id: procedure.id },
              health_insurance_attributes: health_insurance_attributes
            }

            headers = auth_token_for(user)
            post "/api/v1/event_procedures", params: params, headers: headers

            expect(response).to have_http_status(:created)
          end
        end
      end

      context "with invalid attributes" do
        context "when patient_id and patient_name are nil" do
          it "returns unprocessable_entity" do
            headers = auth_token_for(create(:user))
            params = {
              patient_attributes: { id: nil },
              procedure_attributes: { id: nil },
              health_insurance_attributes: { id: nil }
            }
            post "/api/v1/event_procedures", params: params, headers: headers

            expect(response).to have_http_status(:unprocessable_entity)
          end

          it "returns error message" do
            headers = auth_token_for(create(:user))
            patient = create(:patient)
            procedure = create(:procedure)
            health_insurance = create(:health_insurance)
            params = {
              patient_attributes: { id: patient.id },
              procedure_attributes: { id: procedure.id },
              health_insurance_attributes: { id: health_insurance.id }
            }
            post "/api/v1/event_procedures", params: params, headers: headers

            expect(response.parsed_body).to eq(
              "hospital" => ["must exist"],
              "date" => ["can't be blank"],
              "patient_service_number" => ["can't be blank"],
              "room_type" => ["can't be blank"],
              "urgency" => ["is not included in the list"]
            )
          end
        end
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized" do
        params = {
          procedure_id: create(:procedure).id,
          patient_id: create(:patient).id,
          hospital_id: create(:hospital).id,
          health_insurance_id: create(:health_insurance).id,
          patient_service_number: "1234567890",
          date: Time.zone.now.to_date,
          urgency: false,
          amount_cents: 100,
          room_type: EventProcedures::RoomTypes::WARD,
          payment: EventProcedures::Payments::HEALTH_INSURANCE
        }

        post "/api/v1/event_procedures", params: params, headers: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PUT /api/v1/event_procedures/:id" do
    context "when user is authenticated" do
      context "with valid attributes and the record belongs to the user" do
        it "returns ok" do
          user = create(:user)
          event_procedure = create(:event_procedure, user_id: user.id)

          params = {
            procedure_id: create(:procedure).id,
            patient_id: create(:patient).id,
            hospital_id: create(:hospital).id,
            health_insurance_id: create(:health_insurance).id,
            patient_service_number: "1234567890",
            date: Time.zone.now.to_date,
            urgency: false,
            room_type: EventProcedures::RoomTypes::WARD,
            payment: EventProcedures::Payments::HEALTH_INSURANCE
          }

          headers = auth_token_for(user)
          put "/api/v1/event_procedures/#{event_procedure.id}", params: params, headers: headers

          expect(response).to have_http_status(:ok)
        end
      end

      context "with valid attributes and the record not belongs to the user" do
        it "returns unauthorized" do
          user = create(:user)
          event_procedure = create(:event_procedure)

          params = {
            procedure_id: create(:procedure).id,
            patient_id: create(:patient).id,
            hospital_id: create(:hospital).id,
            health_insurance_id: create(:health_insurance).id,
            patient_service_number: "1234567890",
            date: Time.zone.now.to_date,
            urgency: false,
            room_type: EventProcedures::RoomTypes::WARD,
            payment: EventProcedures::Payments::HEALTH_INSURANCE
          }

          headers = auth_token_for(user)
          put "/api/v1/event_procedures/#{event_procedure.id}", params: params, headers: headers

          expect(response).to have_http_status(:unauthorized)
        end
      end

      context "with invalid attributes" do
        it "returns unprocessable_entity" do
          user = create(:user)
          event_procedure = create(:event_procedure, user_id: user.id)

          headers = auth_token_for(user)
          put "/api/v1/event_procedures/#{event_procedure.id}", params: { date: nil }, headers: headers

          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns error message" do
          user = create(:user)
          event_procedure = create(:event_procedure, user_id: user.id)

          headers = auth_token_for(user)
          put "/api/v1/event_procedures/#{event_procedure.id}", params: { date: nil }, headers: headers

          expect(response.parsed_body).to eq(["Date can't be blank"])
        end
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized" do
        user = create(:user)
        event_procedure = create(:event_procedure, user_id: user.id)

        params = {
          procedure_id: create(:procedure).id,
          patient_id: create(:patient).id,
          hospital_id: create(:hospital).id,
          health_insurance_id: create(:health_insurance).id,
          patient_service_number: "1234567890",
          date: Time.zone.now.to_date,
          urgency: false,
          room_type: EventProcedures::RoomTypes::WARD,
          payment: EventProcedures::Payments::HEALTH_INSURANCE
        }

        put "/api/v1/event_procedures/#{event_procedure.id}", params: params, headers: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /api/v1/event_procedures/:id" do
    context "when user is authenticated" do
      it "returns ok" do
        user = create(:user)
        event_procedure = create(:event_procedure, user_id: user.id)

        headers = auth_token_for(user)
        delete "/api/v1/event_procedures/#{event_procedure.id}", headers: headers

        expect(response).to have_http_status(:ok)
      end

      context "when event_procedure cannot be destroyed" do
        it "returns unprocessable_entity" do
          user = create(:user)
          event_procedure = create(:event_procedure, user_id: user.id)

          allow(EventProcedure).to receive(:find).with(event_procedure.id.to_s).and_return(event_procedure)
          allow(event_procedure).to receive(:destroy).and_return(false)

          headers = auth_token_for(user)
          delete "/api/v1/event_procedures/#{event_procedure.id}", headers: headers

          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns error message" do
          user = create(:user)
          event_procedure = create(:event_procedure, user_id: user.id)

          allow(EventProcedure).to receive(:find).with(event_procedure.id.to_s).and_return(event_procedure)
          allow(event_procedure).to receive(:destroy).and_return(false)

          headers = auth_token_for(user)
          delete "/api/v1/event_procedures/#{event_procedure.id}", headers: headers

          expect(response.parsed_body).to eq("cannot_destroy")
        end
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized" do
        event_procedure = create(:event_procedure)

        delete "/api/v1/event_procedures/#{event_procedure.id}", headers: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
