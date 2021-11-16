require 'frameit/device'

describe Frameit::Device do
  def screen_size_from(path)
    path.match(/{([0-9]+)x([0-9]+)}/).captures.map(&:to_i)
  end

  before do
    allow(FastImage).to receive(:size) do |path|
      screen_size_from(path)
    end

    Frameit.config = instance_double("FastlaneCore::Configuration")
    allow(Frameit.config).to receive(:[]).with(anything).and_return(false)
  end

  Devices = Frameit::Devices
  Platform = Frameit::Platform

  # Ensure that devices are correctly detected based on resolutions, priorities and settings
  describe "#detect_device" do
    def expect_screen_size_from_file(file, platform)
      expect(Frameit::Device.detect_device(file, platform))
    end

    def expect_forced_screen_size(value)
      expect(Frameit::Device.find_device_by_id_or_name(value))
    end

    describe "valid iOS screen sizes" do
      it "should detect iPhone XS in portrait and landscape if filename contains \"Apple iPhone XS\"" do
        expect_screen_size_from_file("Apple iPhone XS-Portrait{1125x2436}.jpg", Platform::IOS).to eq(Devices::IPHONE_XS)
        expect_screen_size_from_file("Apple iPhone XS-Landscape{2436x1125}.jpg", Platform::IOS).to eq(Devices::IPHONE_XS)
      end

      it "should detect iPhone 12 Mini in portrait and landscape based on priority" do
        expect_screen_size_from_file("screenshot-Portrait{1125x2436}.jpg", Platform::IOS).to eq(Devices::IPHONE_12_MINI)
        expect_screen_size_from_file("screenshot-Landscape{2436x1125}.jpg", Platform::IOS).to eq(Devices::IPHONE_12_MINI)
      end

      it "should detect iPhone X instead of iPhone XS because of the file name containing device name" do
        expect_screen_size_from_file("Apple iPhone X-Portrait{1125x2436}.jpg", Platform::IOS).to eq(Devices::IPHONE_X)
        expect_screen_size_from_file("Apple iPhone X-Landscape{2436x1125}.jpg", Platform::IOS).to eq(Devices::IPHONE_X)
      end

      it "should detect iPhone X instead of iPhone XS because of the file name containing device ID" do
        expect_screen_size_from_file("iphone-X-Portrait{1125x2436}.jpg", Platform::IOS).to eq(Devices::IPHONE_X)
        expect_screen_size_from_file("iphone-X-Landscape{2436x1125}.jpg", Platform::IOS).to eq(Devices::IPHONE_X)
      end

      it "should detect iPhone X instead of iPhone XS because of CLI parameters or fastfile" do
        allow(Frameit.config).to receive(:[]).with(:use_legacy_iphonex).and_return(true)
        expect_screen_size_from_file("screenshot-Portrait{1125x2436}.jpg", Platform::IOS).to eq(Devices::IPHONE_X)
        expect_screen_size_from_file("screenshot-Landscape{2436x1125}.jpg", Platform::IOS).to eq(Devices::IPHONE_X)
      end

      it "should detect Apple iPad Pro (12.9-inch) (4th generation) in portrait and landscape if filename contains \"iPad Pro (12.9-inch) (4th generation)\"" do
        expect_screen_size_from_file("iPad Pro (12.9-inch) (4th generation)-Portrait{2048x2732}.jpg", Platform::IOS).to eq(Devices::IPAD_PRO_12_9)
        expect_screen_size_from_file("iPad Pro (12.9-inch) (4th generation)-Landscape{2732x2048}.jpg", Platform::IOS).to eq(Devices::IPAD_PRO_12_9)
      end

      it "should detect Apple iPad Pro (12.9-inch) (4th generation) in portrait and landscape if filename contains \"iPad\" based on resolution and priority" do
        expect_screen_size_from_file("iPad-Portrait{2048x2732}.jpg", Platform::IOS).to eq(Devices::IPAD_PRO_12_9)
        expect_screen_size_from_file("iPad-Landscape{2732x2048}.jpg", Platform::IOS).to eq(Devices::IPAD_PRO_12_9)
      end

      it "should detect Apple iPad Pro (12.9-inch) (2nd generation) in portrait and landscape if filename contains \"iPad Pro (12.9-inch) (2nd generation)\"" do
        expect_screen_size_from_file("iPad Pro (12.9-inch) (2nd generation)-Portrait{2048x2732}.jpg", Platform::IOS).to eq(Devices::IPAD_PRO_12_9_2ND_GEN)
        expect_screen_size_from_file("iPad Pro (12.9-inch) (2nd generation)-Landscape{2732x2048}.jpg", Platform::IOS).to eq(Devices::IPAD_PRO_12_9_2ND_GEN)
      end

      it "should detect Apple iPad Pro (aka 2nd gen) in portrait and landscape if filename contains \"iPad Pro (12.9-inch)\" based on filename" do
        expect_screen_size_from_file("iPad Pro (12.9-inch)-Portrait{2048x2732}.jpg", Platform::IOS).to eq(Devices::IPAD_PRO_12_9_2ND_GEN_BC)
        expect_screen_size_from_file("iPad Pro (12.9-inch)-Landscape{2732x2048}.jpg", Platform::IOS).to eq(Devices::IPAD_PRO_12_9_2ND_GEN_BC)
      end

      it "should detect Apple iPad Pro (11-inch) (2nd generation) in portrait and landscape if filename contains \"iPad Pro (11-inch) (2nd generation)\"" do
        expect_screen_size_from_file("iPad Pro (11-inch) (2nd generation)-Portrait{1668x2388}.jpg", Platform::IOS).to eq(Devices::IPAD_PRO_11)
        expect_screen_size_from_file("iPad Pro (11-inch) (2nd generation)-Landscape{2388x1668}.jpg", Platform::IOS).to eq(Devices::IPAD_PRO_11)
      end

      it "should detect Apple iPad Pro (11-inch) in portrait and landscape if filename contains \"iPad Pro (11-inch)\" based on filename" do
        expect_screen_size_from_file("iPad Pro (11-inch)-Portrait{1668x2388}.jpg", Platform::IOS).to eq(Devices::IPAD_PRO_11_BC)
        expect_screen_size_from_file("iPad Pro (11-inch)-Landscape{2388x1668}.jpg", Platform::IOS).to eq(Devices::IPAD_PRO_11_BC)
      end

      it "should detect Apple iPad Air (3rd generation) in portrait and landscape if filename contains \"iPad Air\" based on priority" do
        expect_screen_size_from_file("iPad Air-Portrait{1668x2224}.jpg", Platform::IOS).to eq(Devices::IPAD_AIR)
        expect_screen_size_from_file("iPad Air-Landscape{2224x1668}.jpg", Platform::IOS).to eq(Devices::IPAD_AIR)
      end

      it "should detect Apple iPad Air 2 in portrait and landscape if filename contains \"iPad Air 2\"" do
        expect_screen_size_from_file("iPad Air 2-Portrait{1536x2048}.jpg", Platform::IOS).to eq(Devices::IPAD_AIR_2)
        expect_screen_size_from_file("iPad Air 2-Landscape{2048x1536}.jpg", Platform::IOS).to eq(Devices::IPAD_AIR_2)
      end

      it "should detect Apple iPad Air 2 in portrait and landscape if filename contains \"iPad\" based on resolution and priority" do
        expect_screen_size_from_file("iPad-Portrait{1536x2048}.jpg", Platform::IOS).to eq(Devices::IPAD_AIR_2)
        expect_screen_size_from_file("iPad-Landscape{2048x1536}.jpg", Platform::IOS).to eq(Devices::IPAD_AIR_2)
      end

      it "should detect Apple iPad Mini (5th generation) in portrait and landscape if filename contains \"iPad Air Mini\" based on priority" do
        expect_screen_size_from_file("iPad Air Mini-Portrait{1536x2048}.jpg", Platform::IOS).to eq(Devices::IPAD_AIR_2)
        expect_screen_size_from_file("iPad Air Mini-Landscape{2048x1536}.jpg", Platform::IOS).to eq(Devices::IPAD_AIR_2)
      end

      it "should detect Apple iPad (7th generation) in portrait and landscape if filename contains \"iPad\" based on resolution" do
        expect_screen_size_from_file("iPad-Portrait{1620x2160}.jpg", Platform::IOS).to eq(Devices::IPAD)
        expect_screen_size_from_file("iPad-Landscape{2160x1620}.jpg", Platform::IOS).to eq(Devices::IPAD)
      end
    end

    describe "valid Android screen sizes" do
      it "should detect Google Pixel 3 XL in portrait and landscape based on priority" do
        expect_screen_size_from_file("pixel-portrait{1440x2960}.png", Platform::ANDROID).to eq(Devices::GOOGLE_PIXEL_3_XL)
        expect_screen_size_from_file("pixel-landscape{2960x1440}.png", Platform::ANDROID).to eq(Devices::GOOGLE_PIXEL_3_XL)
      end

      it "should detect Samsung Galaxy S9 because of file name containing device ID" do
        expect_screen_size_from_file("samsung-galaxy-s9-portrait{1440x2960}.png", Platform::ANDROID).to eq(Devices::SAMSUNG_GALAXY_S9)
        expect_screen_size_from_file("samsung-galaxy-s9-landscape{2960x1440}.png", Platform::ANDROID).to eq(Devices::SAMSUNG_GALAXY_S9)
      end

      it "should detect Samsung Galaxy S8 because of file name containing device name" do
        expect_screen_size_from_file("Samsung Galaxy S8 portrait{1440x2960}.png", Platform::ANDROID).to eq(Devices::SAMSUNG_GALAXY_S8)
        expect_screen_size_from_file("Samsung Galaxy S8 landscape{2960x1440}.png", Platform::ANDROID).to eq(Devices::SAMSUNG_GALAXY_S8)
      end
    end

    describe "force device types" do
      it "should force iPhone X despite arbitrary file name and resolution via device ID" do
        expect_forced_screen_size("iphone-X").to eq(Devices::IPHONE_X)
      end

      it "should force iPhone X despite arbitrary file name and resolution via device name" do
        expect_forced_screen_size("iPhone X").to eq(Devices::IPHONE_X)
      end

      it "should force iPhone XS despite arbitrary file name and resolution via Deliver::AppScreenshot::ScreenSize" do
        expect_forced_screen_size("iOS-5.8-in").to eq(Devices::IPHONE_XS)
      end
    end

    describe "invalid screen sizes" do
      def expect_invalid_screen_size_from_file(file, platform)
        expect do
          Frameit::Device.detect_device(file, platform)
        end.to raise_error(FastlaneCore::Interface::FastlaneError, "Unsupported screen size #{screen_size_from(file)} for path '#{file}'")
      end

      it "shouldn't allow arbitrary unsupported resolution 1080x1000" do
        expect_invalid_screen_size_from_file("unsupported-device-NativeResolution{1080x1000}.jpg", Platform::IOS)
        expect_invalid_screen_size_from_file("Apple iPad Air 2{1000x1080}.jpg", Platform::IOS)
      end
    end
  end
end
