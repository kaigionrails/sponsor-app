class Admin::PlansController < Admin::ApplicationController
  before_action :set_conference
  before_action :set_plan, only: [:show, :edit, :update, :destroy]

  def new
    @plan = Plan.new(conference: @conference)
  end

  def edit
  end

  def create
    @plan = Plan.new(plan_params)
    @plan.conference = @conference

    respond_to do |format|
      if @plan.save
        format.html { redirect_to edit_conference_plan_path(@conference, @plan), notice: 'Plan was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @plan.update(plan_params)
        format.html { redirect_to edit_conference_plan_path(@conference, @plan), notice: 'Plan was successfully updated.' }
      else
        format.html { render :new }
      end
    end
  end

  private

  def plan_params
    params.require(:plan).permit(
      :name,
      :rank,
      :price_text,
      :summary,
      :capacity,
      :number_of_guests,
      :booth_size,
      :words_limit,
      :auto_acceptance,
      :commercial_message_movie_eligible,
      :closes_at,
    )
  end

  def set_conference
    @conference = Conference.find_by!(slug: params[:conference_slug])
    check_staff_conference_authorization!(@conference)
  end

  def set_plan
    @plan = Plan.where(conference: @conference).find(params[:id])
  end
end
