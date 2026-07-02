from PIL import Image
import sys

def pad_image(input_path, output_path, scale_factor=0.65):
    try:
        # Open original image
        img = Image.open(input_path)
        img = img.convert("RGBA")
        
        # Calculate new size
        new_width = int(img.width * scale_factor)
        new_height = int(img.height * scale_factor)
        
        # Resize image
        resized_img = img.resize((new_width, new_height), Image.Resampling.LANCZOS)
        
        # Create a new blank (transparent) canvas of the original size
        new_canvas = Image.new("RGBA", (img.width, img.height), (0, 0, 0, 0))
        
        # Calculate position to paste the resized image (centered)
        paste_x = (img.width - new_width) // 2
        paste_y = (img.height - new_height) // 2
        
        # Paste
        new_canvas.paste(resized_img, (paste_x, paste_y), resized_img)
        
        # Save over the original or as a new file
        new_canvas.save(output_path)
        print(f"Successfully padded {input_path} to {output_path}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python pad_icon.py <input> <output>")
    else:
        pad_image(sys.argv[1], sys.argv[2])
