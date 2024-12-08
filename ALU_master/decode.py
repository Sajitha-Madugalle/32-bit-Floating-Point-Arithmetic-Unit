import struct

def ieee754_to_float(hex_value):
    """
    Converts a 32-bit IEEE 754 hexadecimal number to a decimal float.
    """
    try:
        # Convert hex string to binary bytes
        binary_data = bytes.fromhex(hex_value)
        # Unpack as a float (IEEE 754 single precision)
        return struct.unpack('!f', binary_data)[0]
    except ValueError:
        # Handle invalid hex values (e.g., "xxxxxxxx")
        return "undefined"

def decode_selection(selection_binary):
    """
    Decodes the binary selection into its operation symbol.
    """
    mapping = {
        '00': '+',  # addition
        '01': '-',  # subtraction
        '10': '×',  # multiplication
        '11': '÷'   # division
    }
    return mapping.get(selection_binary, 'unknown')

def decode_file(file_path):
    """
    Decodes the provided file line by line.
    """
    with open(file_path, 'r') as file:
        for line in file:
            # Split the line into parts
            parts = line.strip().split()
            
            # Ensure the line has the correct number of components
            if len(parts) != 7:
                print(f"Invalid line format: {line}")
                continue
            
            # Parse the components
            time = parts[0]  # Time (unused)
            selection = parts[1]
            A_hex = parts[2]
            B_hex = parts[3]
            out_hex = parts[4]
            exception = parts[5]  # Exception (unused)
            zerodivide = parts[6]  # Zero divide (unused)

            # Decode the selection and convert the values
            operation = decode_selection(selection)
            A = ieee754_to_float(A_hex)
            B = ieee754_to_float(B_hex)
            out = ieee754_to_float(out_hex)

            # Print the formatted results
            if A == "undefined" or B == "undefined" or out == "undefined":
                print(f"Operation: {operation}, Result: undefined")
            else:
                print(f"{A} {operation} {B} = {out}")

# Example usage:
# Replace 'path/to/your/file.txt' with the actual file path
decode_file('out.txt')
