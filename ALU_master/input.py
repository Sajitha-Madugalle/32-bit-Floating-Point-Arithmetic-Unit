import struct
import tkinter as tk
from tkinter import messagebox
import os

def float_to_ieee754(num):
    """Convert a float to IEEE 754 single precision format."""
    try:
        packed = struct.pack('>f', float(num))
        return '32\'h{:08x}'.format(struct.unpack('>I', packed)[0])
    except ValueError:
        return None

def process_data(input_lines):
    count = 0
    results = []

    for line in input_lines:
        line = line.strip()

        numbers = line.split()

        if len(numbers) != 2:
            results.append(f"//invalid number: {line}")
            continue

        num1, num2 = numbers
        ieee_num1 = float_to_ieee754(num1)
        ieee_num2 = float_to_ieee754(num2)

        if ieee_num1 is None or ieee_num2 is None:
            results.append(f"//invalid number: {line}")
            continue

        results.append(f"A_mem[{count}]={ieee_num1}; B_mem[{count}]={ieee_num2}; // {num1} {num2}")
        count += 1

    return results

def save_verilog_file(results):
    verilog_code = """module instructions (
    input clk,
    input loadData,
    output reg [31:0] A,
    output reg [31:0] B
);
    // Memory for A and B values
    reg [31:0] A_mem [0:15];
    reg [31:0] B_mem [0:15];
    reg [3:0] index;            // Index for current data
    reg loadData_prev;          // Register to detect edge of loadData
    reg loadData_valid;         // Signal to trigger data transfer

    initial begin
        // Initialize memory
"""

    for result in results:
        verilog_code += f"        {result}\n"

    verilog_code += """        index = 0;               // Start at first data pair 
        A = 32'b0;
        B = 32'b0;
        loadData_prev = 0;
        loadData_valid = 0;
    end

    // Detect loadData edge
    always @(posedge clk) begin
        if (loadData && !loadData_prev) begin
            // Rising edge of loadData detected
            loadData_valid <= 1;
        end

        // Update loadData_prev to track edge
        loadData_prev <= loadData;

        // Load data on the first rising edge after loadData goes high
        if (loadData_valid) begin
            A <= A_mem[index];
            B <= B_mem[index];
            index <= index + 1;

            if (index == 15) begin
                index <= 0;        // Wrap around if last data is reached
            end

            loadData_valid <= 0;   // Clear valid signal after loading
        end
    end
endmodule"""

    file_path = os.path.join(os.getcwd(), "instructions.v")
    with open(file_path, "w") as f:
        f.write(verilog_code)
    messagebox.showinfo("Success", f"Verilog file saved as {file_path}")

def main():
    def process_and_save():
        input_lines = text_input.get("1.0", tk.END).splitlines()
        results = process_data(input_lines)
        save_verilog_file(results)

    root = tk.Tk()
    root.title("IEEE 754 Converter and Verilog Generator")

    frame = tk.Frame(root)
    frame.pack(pady=10, padx=10)

    instructions = tk.Label(frame, text="Enter space-separated floating-point numbers. Each pair forms A and B.\nPress the button below to finish and generate the Verilog file.", justify="left")
    instructions.pack(pady=5)

    text_input = tk.Text(frame, width=60, height=20)
    text_input.pack()

    btn_process = tk.Button(frame, text="Generate Verilog File", command=process_and_save)
    btn_process.pack(pady=10)

    root.mainloop()

if __name__ == "__main__":
    main()
