from matplotlib import pyplot as plt
import numpy as np

x = [1,2,3,4,5]
y = [1,2,3,4,5]
z = [1,1,1,1,1]

plt.plot(y)
plt.fill_between(x, y, z)
plt.show()
