import Swiftline
import Commander


command {
    let isSDK = agree("要不要打开原生支付 SDK工程?")
    let openBranch = OpenBranch(sdk:isSDK)
    do {
        try openBranch.open()
    } catch let error {
        print(error.localizedDescription.f.Yellow.b.Red)
    }
}.run()

