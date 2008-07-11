import Distribution.Simple
import Distribution.PackageDescription
import Distribution.Simple.LocalBuildInfo

import System.Directory
import System.Cmd
import System.Exit
import Control.Monad


main = defaultMainWithHooks simpleUserHooks{runTests=test}


test :: CabalBreaksTheAPI_Grr grr => Args -> Bool -> PackageDescription -> LocalBuildInfo -> IO grr
test args bool pd lbi = do
    putStrLn "Make sure you have installed the derive you wish to test!"
    cur <- getCurrentDirectory
    setCurrentDirectory "tests"
    
    b <- doesFileExist "Small.out.hs"
    when b $ removeFile "Small.out.hs"
    i <- system $ "derive -mSmallInstances -iSmall -iData.Generics -iData.Monoid " ++
                  "-o Small.out.hs Small.hs"

    b <- doesFileExist "Small.out.hs"
    if b then system "diff -u -b Small.expected.hs Small.out.hs" >> return ()
         else putStrLn "Error: Failed to generate the output file"
    
    -- currently we turn off warnings when compiling
    -- it would be nice if we made the generated code compile without warnings
    system "ghc --make -c -w Small.out.hs"
    setCurrentDirectory cur
    return grr


class CabalBreaksTheAPI_Grr a where
    grr :: a

instance CabalBreaksTheAPI_Grr () where
    grr = ()

instance CabalBreaksTheAPI_Grr ExitCode where
    grr = ExitSuccess
