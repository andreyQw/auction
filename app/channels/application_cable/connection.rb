# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private
      def find_verified_user
        uid = request.headers["uid"]
        token = request.headers["access-token"]
        client_id = request.headers["client"]

        user = User.find_by_uid(uid)

        if user && user.valid_token?(token, client_id)
          user
        else
          reject_unauthorized_connection
        end
      end
  end
end
