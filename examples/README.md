这是一个 [**React Native**](https://reactnative.dev) 工程，包含react-native-video的HarmonyOS侧示例和调试

# 运行example示例

## Step 1: 根目录安装依赖

react-native-video**根目录**安装依赖

```bash
# using npm
npm install
```

## Step 2: examples目录依赖

安装examples所需的依赖

```bash
cd ./examples
```

```bash
# using npm
npm install
```

安装video依赖

```bash
# using npm
npm run install:video
```

## Step 3: 编译RN的bundle

在examples目录下运行npm run start命令和端口映射

```bash
# using npm
npm run start
```

```bash
# using npm
npm run hdc:tcp
```

## Step 4: 编译Harmony工程

使用Harmony工程的工具DevEco Studio打开examples目录下的harmony工程，等待IDE安装完依赖，运行安装即可
