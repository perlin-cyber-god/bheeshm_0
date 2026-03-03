import pandas as pd
import numpy as np
from sklearn.linear_model import Perceptron
from sklearn.preprocessing import MinMaxScaler

print("1. Loading UNSW-NB15 Dataset...")
# Update this path if your CSV has a slightly different name!
df = pd.read_csv('archive(1)/UNSW_NB15_testing-set.csv')

print("2. Extracting Features...")
# We pick 4 features that indicate DDoS or flooding attacks
# sttl: Source to destination time to live
# rate: Packets per second
# sload: Source bits per second
# dload: Destination bits per second
features = ['sttl', 'rate', 'sload', 'dload']

X = df[features].fillna(0)
y = df['label'] # 0 = Normal Traffic, 1 = Attack Traffic

# Scale the data to be between 0 and 255 (8-bit hardware limits)
scaler = MinMaxScaler(feature_range=(0, 255))
X_scaled = scaler.fit_transform(X)

print("3. Training the AI Hardware Neuron...")
# This trains the exact (Weight * Input) + Bias math we wrote in Verilog
clf = Perceptron(max_iter=1000, tol=1e-3)
clf.fit(X_scaled, y)

print("4. Quantizing for FPGA (Converting to Integers)...")
# Extract floats and scale them up to integers so the FPGA can use them
raw_weights = clf.coef_[0]
raw_bias = clf.intercept_[0]

# Multiply by a scaling factor to remove decimals, then convert to int
SCALE_FACTOR = 100 
verilog_weights = np.round(raw_weights * SCALE_FACTOR).astype(int)
verilog_bias = int(np.round(raw_bias * SCALE_FACTOR))

print("\n==================================================")
print("🎯 TRAINING COMPLETE! HERE IS YOUR VERILOG HARDWARE:")
print("==================================================")
print(f"Weight 1 (sttl)  : {verilog_weights[0]}")
print(f"Weight 2 (rate)  : {verilog_weights[1]}")
print(f"Weight 3 (sload) : {verilog_weights[2]}")
print(f"Weight 4 (dload) : {verilog_weights[3]}")
print(f"Bias             : {verilog_bias}")
print("==================================================")
print("Copy these numbers. We will put them into bheeshm_core.v next.")