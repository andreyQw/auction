# frozen_string_literal: true

# == Schema Information
#
# Table name: lots
#
#  id                :integer          not null, primary key
#  bid_win           :integer
#  current_price     :float            not null
#  description       :string
#  estimated_price   :float            not null
#  image             :string
#  job_id_closed     :string
#  job_id_in_process :string
#  lot_end_time      :datetime         not null
#  lot_start_time    :datetime         not null
#  status            :integer          default("pending")
#  title             :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  user_id           :integer
#  user_win_id       :integer
#
# Indexes
#
#  index_lots_on_status   (status)
#  index_lots_on_user_id  (user_id)
#

class Lot < ApplicationRecord
  belongs_to :user
  belongs_to :winner, class_name: "User", foreign_key: "user_win_id", required: false
  has_many :bids
  has_one :order

  after_create :push_job_id_to_lot
  after_update :update_lot_jobs, :send_mail_after_closed

  mount_uploader :image, LotImageUploader

  scope :my_lots_all, -> (current_user_id) { left_joins(:bids).where("lots.user_id = :user_id OR bids.user_id = :user_id", user_id: current_user_id).distinct }
  scope :my_lots_created, -> (current_user_id) { where(user_id: current_user_id) }
  scope :my_lots_participation, -> (current_user_id) { joins(:bids).where("bids.user_id = :user_id", user_id: current_user_id).distinct }

  enum status: [ :pending, :in_process, :closed ]

  validates :image, file_size: { less_than: 1.megabytes }

  validates :title, :current_price, :estimated_price, :lot_start_time, :lot_end_time,  presence: true

  validates :current_price, :estimated_price, numericality: { greater_than: 0 }

  validate :lot_start_time_must_be_more_than_now, :lot_end_time_must_be_more_lot_start_time

  def lot_start_time_must_be_more_than_now
    if lot_start_time < DateTime.now
      errors.add(:lot_start_time, "Lot START time can't be less than current time")
    end
  end

  def lot_end_time_must_be_more_lot_start_time
    if lot_end_time <= lot_start_time
      errors.add(:lot_end_time, "Lot END time can't be less than lot START time")
    end
  end

  #
  def push_job_id_to_lot
    jobs_id = add_lot_jobs
    update_columns(job_id_in_process: jobs_id[:job_id_in_process], job_id_closed: jobs_id[:job_id_closed])
  end

  def update_lot_jobs
    job_in_process = Sidekiq::ScheduledSet.new.find_job(job_id_in_process)
    job_closed = Sidekiq::ScheduledSet.new.find_job(job_id_closed)

    if job_in_process != nil
      job_in_process.delete
    end
    if job_closed != nil
      job_closed.delete
    end
    if bid_win == nil
      jobs_id = add_lot_jobs
      update_columns(job_id_in_process: jobs_id[:job_id_in_process], job_id_closed: jobs_id[:job_id_closed])
    end
  end

  def add_lot_jobs
    job_in_process = LotsStatusInProcessJob.set(wait_until: lot_start_time).perform_later("lot_id:#{id}")
    job_closed = LotsStatusClosedJob.set(wait_until: lot_end_time).perform_later("lot_id:#{id}")

    { job_id_in_process: job_in_process.provider_job_id, job_id_closed: job_closed.provider_job_id }
  end

  def send_mail_after_closed
    if status == "closed"
      UserMailer.email_for_seller_lot_closed self
      if bid_win
        UserMailer.email_for_lot_winner self
      end
    end
  end
end
