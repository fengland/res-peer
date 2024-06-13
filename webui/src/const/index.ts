export enum Apps {
  feedApp = '1db1936dad0717597a7743a8353c9c0191c14c3a129b258e9743aec2b4f05d030600000000000000000000001db1936dad0717597a7743a8353c9c0191c14c3a129b258e9743aec2b4f05d03080000000000000000000000',
  creditApp = '1db1936dad0717597a7743a8353c9c0191c14c3a129b258e9743aec2b4f05d030000000000000000000000001db1936dad0717597a7743a8353c9c0191c14c3a129b258e9743aec2b4f05d03020000000000000000000000',
  marketApp = '1db1936dad0717597a7743a8353c9c0191c14c3a129b258e9743aec2b4f05d030900000000000000000000001db1936dad0717597a7743a8353c9c0191c14c3a129b258e9743aec2b4f05d030b0000000000000000000000',
  reviewApp = '1db1936dad0717597a7743a8353c9c0191c14c3a129b258e9743aec2b4f05d030c00000000000000000000001db1936dad0717597a7743a8353c9c0191c14c3a129b258e9743aec2b4f05d030e0000000000000000000000',
  activityApp = '1db1936dad0717597a7743a8353c9c0191c14c3a129b258e9743aec2b4f05d030f00000000000000020000001db1936dad0717597a7743a8353c9c0191c14c3a129b258e9743aec2b4f05d03110000000000000000000000',
  foundationApp = '1db1936dad0717597a7743a8353c9c0191c14c3a129b258e9743aec2b4f05d030300000000000000000000001db1936dad0717597a7743a8353c9c0191c14c3a129b258e9743aec2b4f05d03050000000000000000000000'
}

export const appIds = Object.values(Apps)

/// Chain which is the application originally deployed
export const appDeployChain = '1db1936dad0717597a7743a8353c9c0191c14c3a129b258e9743aec2b4f05d03'
export const appDeployOwner = 'e43c25379782a593d0f3c8d5c5f090a109d8ab734865386b8e0473dd135775f3'

/// Port should be set with different service
export const port = '9080'
export const host = 'localhost'
