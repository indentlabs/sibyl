class ImagesController < ApplicationController
  before_action :set_image, only: [:show, :edit, :update, :destroy]

  # GET /images
  # GET /images.json
  def index
    search_map = Hash[search_params.keys.zip(search_params.values)].reject { |k, v| !v.present?}

    if search_map == {}
      @images = Image.all.order('created_at desc').includes(:character_image_qualities)
    else
      matched_image_ids = CharacterImageQuality.where(search_map.except('age'))
      if search_params.key?('age')
        matched_image_ids = case search_params['age']
        when 'baby'
          matched_image_ids.where('age < 3')
        when 'child'
          matched_image_ids.where('age >= 3 AND age < 13')
        when 'teenager'
          matched_image_ids.where('age >= 13 AND age < 20')
        when 'young_adult'
          matched_image_ids.where('age >= 18 AND age < 25')
        when 'adult'
          matched_image_ids.where('age >= 25 AND age < 60')
        when 'senior'
          matched_image_ids.where('age >= 60')
        else
          matched_image_ids
        end
      end

      @images = Image.where(id: matched_image_ids.pluck(:image_id)).includes(:character_image_qualities)
    end
  end

  # GET /images/1
  # GET /images/1.json
  def show
  end

  # GET /images/new
  def new
    @image = Image.new
  end

  # GET /images/1/edit
  def edit
  end

  # POST /images
  # POST /images.json
  def create
    @image = Image.new(image_params)

    respond_to do |format|
      if @image.save
        format.html { redirect_to @image, notice: 'Image was successfully created.' }
        format.json { render :show, status: :created, location: @image }
      else
        format.html { render :new }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /images/1
  # PATCH/PUT /images/1.json
  def update
    respond_to do |format|
      if @image.update(image_params)
        format.html { redirect_to @image, notice: 'Image was successfully updated.' }
        format.json { render :show, status: :ok, location: @image }
      else
        format.html { render :edit }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /images/1
  # DELETE /images/1.json
  def destroy
    @image.destroy
    respond_to do |format|
      format.html { redirect_to images_url, notice: 'Image was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_image
    @image = Image.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def image_params
    params.require(:image).permit(:title, :description, :bucket, :filename, :license, :author, :source_url)
  end

  def search_params
    params.permit(:skin_tone, :gender, :age, :glasses)
  end
end
