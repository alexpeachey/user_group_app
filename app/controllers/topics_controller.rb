class TopicsController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :show, :recent]
  before_filter :fetch_topic, except: [:index, :new, :create, :recent]
  before_filter :require_organizer, only: [:destroy]

  # GET /topics
  # GET /topics.json
  def index
    @topics = TopicDecorator.decorate(Topic.open_by_votes)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @topics }
      format.csv { render text: Topic.to_csv }
    end
  end

  # GET /topics/1
  # GET /topics/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @topic }
      format.csv { render text: Topic.to_csv }
    end
  end

  # GET /topics/new
  # GET /topics/new.json
  def new
    @topic = Topic.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @topic }
    end
  end

  # GET /topics/1/edit
  def edit
  end

  # POST /topics
  # POST /topics.json
  def create
    @topic = current_user.topics.build(params[:topic])

    respond_to do |format|
      if @topic.save
        format.html { redirect_to @topic, notice: 'Topic was successfully created.' }
        format.json { render json: @topic, status: :created, location: @topic }
      else
        format.html { render action: "new" }
        format.json { render json: @topic.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /topics/1
  # PUT /topics/1.json
  def update
    respond_to do |format|
      if @topic.update_attributes(params[:topic])
        format.html { redirect_to @topic, notice: 'Topic was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @topic.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /topics/1
  # DELETE /topics/1.json
  def destroy
    @topic.destroy

    respond_to do |format|
      format.html { redirect_to topics_url }
      format.json { head :no_content }
    end
  end

  def vote
    respond_to do |format|
      if current_user.vote_on!(@topic)
        format.html { redirect_to @topic, notice: "You voted!" }
        format.js
      else
        flash[:error] = "Only one vote greedy asshole."
        format.html { redirect_to @topic }
        format.js
      end
    end


  end

  def volunteer
    respond_to do |format|
      if current_user.volunteer_for!(@topic)
        format.html { redirect_to @topic, notice: "Thanks for volunteering!"
 }
        format.js
      else
        flash[:error] = "You should volunteer for another topic."
        format.html { redirect_to @topic }
        format.js
      end
    end
  end

  def recent
    @topics = TopicDecorator.decorate(Topic.open.by_most_recent)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @topics }
    end
  end

  def give_kudo
    respond_to do |format|
      if @topic.give_kudo_as(current_user)
        format.json { head :ok }
        format.html { redirect_to @topic } 
      else
        format.json { render json: @topic.errors.messages.to_json }
        format.html { flash[:error] = @topic.errors.messages and redirect_to @topic } 
      end
    end
  end

  private

  def fetch_topic
    @topic ||= TopicDecorator.find(params[:id])
  end
end
