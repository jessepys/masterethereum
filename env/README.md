## 环境搭建

* 搭建solc编译器

```
 npm install -g solc
/usr/local/bin/solcjs -> /usr/local/lib/node_modules/solc/solcjs
+ solc@0.4.21
added 66 packages in 23.622s
```
* 准备部署环境

testrpc 讲道理，部署到真实线上我们是需要连接公共的区块链的，但这里我们只是做实验，所以部署一个仿真的单机区块链就行了。 下载testrpc，它会替我们准备一个单机的区块链环境:

```
 npm install -g ethereumjs-testrpc
```
启动

```
testrpc
```

* 安装web3.js

```
npm i web3
```



