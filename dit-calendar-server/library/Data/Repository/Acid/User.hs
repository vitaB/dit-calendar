{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE RecordWildCards   #-}
{-# LANGUAGE TemplateHaskell   #-}
{-# LANGUAGE TypeFamilies      #-}

module Data.Repository.Acid.User
    ( UserDAO(..), initialUserListState, UserList(..), NewUser(..), UserById(..), AllUsers(..),
    GetUserList(..), UpdateUser(..), DeleteUser(..), FindByLoginName(..) ) where

import           Control.Applicative                ((<$>))
import           Control.Monad.Reader               (ask)
import           Data.Acid                          (Query, Update, makeAcidic)
import           Data.IxSet                         (Indexable (..), getEQ,
                                                     getOne, ixFun, ixSet,
                                                     toList, (@=))
import           Data.Text                          (Text)

import           Data.Domain.Types                  (EitherResponse, UserId)
import           Data.Domain.User                   (User (..))

import qualified Data.Repository.Acid.InterfaceAcid as InterfaceAcid


instance Indexable User where
  empty = ixSet [ ixFun $ \bp -> [ userId bp ],
                  ixFun $ \bp -> [ loginName bp ] ]

type UserList = InterfaceAcid.EntrySet User

initialUserListState :: UserList
initialUserListState = InterfaceAcid.initialState

getUserList :: Query UserList UserList
getUserList = InterfaceAcid.getEntrySet

-- create a new, empty user and add it to the database
newUser :: User -> Update UserList User
newUser = InterfaceAcid.newEntry

userById :: UserId -> Query UserList (Maybe User)
userById = InterfaceAcid.entryById

findByLoginName :: Text -> Query UserList (Maybe User)
findByLoginName loginName = do InterfaceAcid.EntrySet{..} <- ask
                               return $ getOne $ entrys @= loginName

allUsers :: Query UserList [User]
allUsers = InterfaceAcid.allEntrysAsList

updateUser :: User -> Update UserList (EitherResponse User)
updateUser = InterfaceAcid.updateEntry

deleteUser :: UserId -> Update UserList ()
deleteUser = InterfaceAcid.deleteEntry

$(makeAcidic ''UserList ['newUser, 'userById, 'findByLoginName, 'allUsers, 'getUserList, 'updateUser, 'deleteUser])

class UserDAO m where
    create :: NewUser -> m User
    update :: UpdateUser -> m (EitherResponse User)
    delete :: DeleteUser -> m ()
    query  :: UserById -> m (Maybe User)
    queryByLoginName :: FindByLoginName -> m (Maybe User)