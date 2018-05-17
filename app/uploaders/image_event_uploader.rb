class ImageEventUploader < CarrierWave::Uploader::Base
  attr_reader :width, :height
  before :cache, :capture_size
  include CarrierWave::MiniMagick

  storage :file
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def capture_size file
    if version_name.blank?
      if file.path.nil?
        img = MiniMagick::Image.open(file.file)
        @width = img[:width]
        @height = img[:height]
      else
        @width, @height = `identify -format "%wx %h" #{file.path}`.split(/x/).map(&:to_i)
      end
    end
  end

  def default_url
    "placeholders/photos/" + [version_name, "photo28.jpg"].compact.join("_")
  end

  def extension_whitelist
    %w(jpg jpeg gif png)
  end

  version :thumb do
    process :crop_image
  end

  def crop_image
    if model.image_crop_x.present?
      manipulate! do |img|
        x = model.image_crop_x.to_i
        y = model.image_crop_y.to_i
        w = model.image_crop_w.to_i
        h = model.image_crop_h.to_i
        img.crop "#{w}x#{h}+#{x}+#{y}"
      end
    end
  end
end
