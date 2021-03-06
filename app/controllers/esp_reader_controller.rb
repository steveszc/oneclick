class EspReaderController < ApplicationController
  authorize_resource

  def upload
    respond_to do |format|
      format.html
      format.json {}
    end
  end

  def update

    esp = EspReader.new
    @path = upload_esp_reader_index_path
    if params[:esp_upload].nil? || params[:esp_upload][:zip].nil?
      flash[:error] = "No file selected."
      @path = upload_esp_reader_index_path

    else
      result, message = esp.unpack(params[:esp_upload][:zip].tempfile.path, (params[:esp_upload][:csv].first.blank? ? :mdb : :csvzip))
      if result
        #@path = confirm_esp_reader_index_path
        if message.blank?
          flash[:notice] = "ESP services updated successfully."
        else
          flash[:warning] = "ESP services updated with messages: #{message}"
        end
      else
        flash[:error] = message
      end

    end

    respond_to do |format|
      format.html { redirect_to @path }
      #format.js { render "esp_reader/uploadd" }
    end

  end

  def build_polygons
    esp = EspReader.new
    Rails.logger.info "EspReader: add polygons"
    message = nil
    #Add custom polygons for each service and generate the polygons.
    messages = []
    Service.all.each do |service|
      esp.add_paratransit_buffer(service)
      service.build_polygons
    end

    flash[:notice] = "Coverage areas updated."
    @path = services_path
    respond_to do |format|
      format.html { redirect_to @path }
      #format.js { render "esp_reader/uploadd" }
    end
  end

end
