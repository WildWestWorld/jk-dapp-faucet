import { useEffect, useState, useCallback } from "react";
import "./App.css"
import Web3 from "web3";
import detectEthereumProvider from "@metamask/detect-provider";
import { loadContract } from "./utils/load-contract";


function App() {

  const [web3Api, setWeb3Api] = useState({
    provider: null,
    isProviderLoaded: false,
    web3: null,
    contract: null
  })

  const [balance, setBalance] = useState(null)
  const [account, setAccount] = useState(null)
  const [shouldReload, reload] = useState(false)

  const canConnectToContract = account && web3Api.contract

  const reloadEffect = useCallback(() => {
    let state = !shouldReload;
    console.log('reloadEffect', state)
    reload(state)
  }, [shouldReload])

  const setAccountListener = (provider) => {
    provider.on("accountsChanged", _ => window.location.reload())
    provider.on("chainChanged", _ => window.location.reload())

    // provider._jsonRpcConnection.events.on("notification", (payload) => {
    //   const { method } = payload
    //   if (method === "metamask_unlockStateChanged") {
    //     setAccount(null)
    //   }
    // })

  }

  useEffect(() => {
    const loadProvider = async () => {


      const provider = await detectEthereumProvider();

      if (provider) {

        const contract = await loadContract("Faucet", provider)

        setAccountListener(provider);

        setWeb3Api({
          web3: new Web3(provider),
          provider,
          contract,
          isProviderLoaded: true
        })
      } else {
        // setWeb3Api({ ...web3Api, isProviderLoaded: true })

        setWeb3Api((web3Api) => {
          return {
            ...web3Api,
            isProviderLoaded: true
          }
        })

        console.error('Please,install Metamask')
      }



    }
    loadProvider()

  }, [])

  useEffect(() => {
    const loadBalance = async () => {
      const { contract, web3 } = web3Api
      const balance = await web3.eth.getBalance(contract.address)

      setBalance(web3.utils.fromWei(balance, "ether"))
    }
    // console.warn(web3Api.contract)
    web3Api.contract && loadBalance()
  }, [web3Api, shouldReload])


  useEffect(() => {
    const getAccount = async () => {
      const accounts = await web3Api.web3.eth.getAccounts()
      setAccount(accounts[0])
    }
    web3Api.web3 && getAccount()
  }, [web3Api.web3])


  const addFunds = useCallback(async () => {
    const { contract, web3 } = web3Api

    await contract.addFunds({
      from: account,
      value: web3.utils.toWei('1', "ether")
    })

    // window.location.reload()
    reloadEffect()
  }, [web3Api, account, reloadEffect])

  const withDrawFunds = async () => {
    const { contract, web3 } = web3Api
    const withdrawAmount = web3.utils.toWei("0.1", "ether")
    await contract.withdraw(withdrawAmount, {
      from: account,
    })
    reloadEffect()
  }


  return (
    <>
      <div className="faucet-wrapper">
        <div className="faucet">
          {web3Api.isProviderLoaded ?
            < div className="is-flex is-align-items-center">

              <span>
                <strong>Account:</strong>
              </span>

              {account ? <div>{account} </div> : !web3Api.provider ? <>
                <div className="notification is-warning is-small is-rounded">
                  Wallet is not detected!{`  `}
                  <a rel="noreferrer" target="_blank" href="https://docs.metamask.io">
                    Install Metamask
                  </a>
                </div>
              </> : <button className="button is-small" onClick={() => web3Api.provider.request({ method: "eth_requestAccounts" })}>Connect Wallet</button>}
            </div> : <span>
              Looking for Web3..
            </span>
          }
          <div className="balance-view is-size-2 mb-8 my-8">
            Current Balance: <strong>{balance}</strong> ETH
          </div>
          {!canConnectToContract && <i className="is-block">Connect to Ganache</i>}

          {/* <button className="btn mr-2" onClick={async () => {
            const accounts = await window.ethereum.request({ method: "eth_requestAccounts" })
            console.log(accounts)
          }}>Enable Ethereum</button> */}

          <button disabled={!canConnectToContract} className="button is-primary is-light mr-2" onClick={addFunds}>Donate 1ETH</button>
          <button disabled={!canConnectToContract} className="button is-link is-light" onClick={withDrawFunds}>Withdraw 0.1ETH</button>

        </div>
      </div >

    </>

  );
}

export default App;
