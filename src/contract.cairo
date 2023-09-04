use SDID::contract::SDIDContract::{Person,UserEngagement,UserExperience,UserIdentity,UserFinancial};


#[starknet::interface]
trait ISDIDContract<TContractState> {

    fn set_person_tier_one(ref self: TContractState, person:Person) -> felt252;
    fn set_person_tier_two(ref self: TContractState, person:Person) -> felt252;
    fn set_person_tier_three(ref self: TContractState, person:Person) -> felt252;
    fn set_person_tier_four(ref self: TContractState, person:Person) -> felt252;
    fn get_person_tier(self: @TContractState, key:felt252) ->  u64;
    fn get_person_spine(self: @TContractState, key:felt252) ->  felt252;
    fn get_person_experience_data(self: @TContractState, key:felt252) ->  UserExperience;
    fn get_person_engagement_data(self: @TContractState, key:felt252) ->  UserEngagement;
    fn get_person_identity_data(self: @TContractState, key:felt252) ->  UserIdentity;
    fn get_person_finacial_data(self: @TContractState, key:felt252) ->  UserFinancial;
}

#[starknet::contract]
mod SDIDContract {
    use poseidon::poseidon_hash_span;
    use array::ArrayTrait;
    use starknet::ContractAddress;
    use core::debug::PrintTrait;

     
    #[storage]
    struct Storage {
        personDID: LegacyMap::<felt252, Person>,
        tierDID: LegacyMap::<felt252, u64>,
        user_spineDID: LegacyMap::<felt252, felt252>,
        user_experienceDID: LegacyMap::<felt252, UserExperience>,
        user_identityDID: LegacyMap::<felt252, UserIdentity>,
        user_engagementDID: LegacyMap::<felt252, UserEngagement>,
        user_financialInfo:LegacyMap::<felt252, UserFinancial>,

    }

    #[derive(Copy, Drop, Serde, starknet::Store)]
    struct Person {
        user_spine: UserSpine,
        user_experience: UserExperience,
        user_identity: UserIdentity,
        user_engagement: UserEngagement,
        user_financial:UserFinancial,
    }

    #[derive(Copy, Drop, Serde, starknet::Store)]
    struct UserSpine {
        first_name: felt252,
        last_name: felt252,
        phone_number: felt252,
        email: felt252,
        address: felt252,
        secret_word : felt252,
    }


    #[derive(Copy, Drop, Serde, starknet::Store)]
    struct UserExperience {
        profile_picture: felt252, // CID
        bio: felt252, // CID
        social_media_links: felt252, //CID
        languages:felt252, //CID
        hobbies: felt252, // CID
        interests: felt252, // CID
    }


    #[derive(Copy, Drop, Serde, starknet::Store)]
    struct UserIdentity {
        gender: felt252,
        date_of_birth: felt252,
        nationality: felt252,
        passport_number: felt252,
        driver_license_number: felt252,
        personal_identifier: felt252,
        unique_identifier: felt252,
    }

    #[derive(Copy, Drop, Serde, starknet::Store)]
    struct UserEngagement{
        location:felt252,
        education: felt252,  //// CID
        occupation: felt252,// CID
        employer: felt252, // CID
        marital_status: felt252,

        
    }

    #[derive(Copy, Drop, Serde, starknet::Store)]
    struct UserFinancial{
        user: ContractAddress,
        stark_worth: u64,
        
    }
    

    #[external(v0)]
    #[generate_trait]
    impl SDIDContract of ISDIDContract {
        fn set_person_tier_one(ref self: ContractState,value:Person) -> felt252{
            let person_tier:u64 = 1;
            let user_hashed_key = self._get_hashing_result(value,person_tier);
            user_hashed_key
            
        }
        fn set_person_tier_two(ref self: ContractState,value:Person) -> felt252{
            let person_tier:u64 = 2;
            let user_hashed_key = self._get_hashing_result(value,person_tier);
            user_hashed_key
            
        }
        fn set_person_tier_three(ref self: ContractState,value:Person) -> felt252{
            let person_tier:u64 = 3;
            let user_hashed_key = self._get_hashing_result(value,person_tier);
            user_hashed_key
            
        }
        fn set_person_tier_four(ref self: ContractState,value:Person) -> felt252{
            let person_tier:u64 = 4;
            let user_hashed_key = self._get_hashing_result(value,person_tier);
            user_hashed_key
            
        }
        fn get_person_tier(self: @ContractState, key: felt252) -> u64 {
            let pers = self.tierDID.read(key);
            pers
            
        }

        fn get_person_spine(self: @ContractState, key: felt252) -> felt252 {
            let person_spine = self._get_user_spine(key);
            person_spine
            
        }

        fn get_person_experience_data(self: @ContractState, key: felt252) -> UserExperience{
            let user_experience = self.user_experienceDID.read(key);
            user_experience
        }

        fn get_person_identity_data(self: @ContractState, key: felt252) -> UserIdentity{
            let user_identity = self.user_identityDID.read(key);
            user_identity
        }

        fn get_person_engagement_data(self: @ContractState, key: felt252) -> UserEngagement{
            let user_engagement = self.user_engagementDID.read(key);
            user_engagement
        }
 
        fn get_person_finacial_data(self: @ContractState, key: felt252) -> UserFinancial{
            let user_financial = self.user_financialInfo.read(key);
            user_financial
        }

    }


    #[generate_trait]
    impl SDIDContractFunctionsImpl of SDIDContractFunctionsTrait {
        // @dev Internal function to generate hashes
        fn _get_hashing_result(ref self: ContractState,value:Person, tier:u64) -> felt252{
            let mut serialized: Array<felt252> = ArrayTrait::new();
            Serde::<Person>::serialize(@value, ref serialized);
            let person = serialized.span();
            let hashed_key = poseidon_hash_span(serialized.span());
            
            let user_hashed_key = poseidon_hash_span(person);
            self.personDID.write(hashed_key,value);
            
           

            let mut serialized_spine: Array<felt252> = ArrayTrait::new();
            Serde::<UserSpine>::serialize(@value.user_spine, ref serialized_spine);
            let hashed_spine = poseidon_hash_span(serialized_spine.span());
            self.user_spineDID.write(hashed_key,hashed_spine);

            self.tierDID.write(hashed_key,tier);

            if tier == 2{
                self.user_identityDID.write(hashed_key,value.user_identity);
            }

            if tier == 3 {
                self.user_identityDID.write(hashed_key,value.user_identity);
                self.user_experienceDID.write(hashed_key,value.user_experience);
            }

            if tier == 4 {
                self.user_identityDID.write(hashed_key,value.user_identity);
                self.user_experienceDID.write(hashed_key,value.user_experience);
                self.user_engagementDID.write(hashed_key,value.user_engagement);
            }
            

            user_hashed_key 
        }

        fn _get_user_spine(self: @ContractState, key: felt252) -> felt252{
            let pers = self.user_spineDID.read(key);
            pers
        }

        fn _get_user_experience(self: @ContractState, key: felt252) -> UserExperience{
            let user_experience = self.user_experienceDID.read(key);
            user_experience
        }

        fn _get_user_identity(self: @ContractState, key: felt252) -> UserIdentity{
            let user_identity = self.user_identityDID.read(key);
            user_identity
        }

        fn _get_user_engagement(self: @ContractState, key: felt252) -> UserEngagement{
            let user_engagement = self.user_engagementDID.read(key);
            user_engagement
        }

        fn _get_user_financial(self: @ContractState, key: felt252) -> UserFinancial{
            let user_financial = self.user_financialInfo.read(key);
            user_financial
        }

      
    }

}




#[cfg(test)]
mod tests {
    use core::debug::PrintTrait;
    use SDID::contract::ISDIDContractDispatcherTrait;
    use core::array::ArrayTrait;
    use super::SDIDContract;
    use super::{ISDIDContractDispatcher};
    use SDIDContract::{Person,UserSpine,UserExperience,UserIdentity,UserEngagement,UserFinancial};
    use starknet::deploy_syscall;
    use starknet::class_hash::Felt252TryIntoClassHash;
    use poseidon::poseidon_hash_span;
    use starknet::{ContractAddress,contract_address_const};


       // Deploy the contract and return its dispatcher.
    fn deploy() -> ISDIDContractDispatcher {
        // Set up constructor arguments.
        let mut calldata: Array<felt252> = ArrayTrait::new();
        let (address0, _) = deploy_syscall(SDIDContract::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false).unwrap();

        // Return the dispatcher.
        // The dispatcher allows to interact with the contract based on its interface.
        ISDIDContractDispatcher { contract_address: address0 }
    }


    fn person_data() -> Person{

        let userContractAddress: ContractAddress =  contract_address_const::<0x00000>();


        let userSpine = UserSpine {
            first_name: 'John',
            last_name: 'Doe',
            phone_number: '07784389382',
            email: 'john@example.com',
            address: '3 123 56',
            secret_word : 'XXXXXXXX',
        };

        let userExperience = UserExperience {
            profile_picture: 'CID-ProfilePicture', // CID for the profile picture
            bio: 'CID-Bio', // CID for the bio
            social_media_links: 'CID-SocialMediaLinks', // CID for social media links
            languages: 'CID-Languages', // CID for languages
            hobbies: 'CID-Hobbies', // CID for hobbies
            interests: 'CID-Interests', // CID for interests
        };


        //  let userExperience =   UserExperience::default;

        
        let userIdentity = UserIdentity {
            gender: 'Male', // Gender
            date_of_birth: '1990-01-01', // Date of birth
            nationality: 'Kenyan', // Nationality
            passport_number: 'ABC123456', // Passport number
            driver_license_number: 'XYZ789', // Driver's license number
            personal_identifier: '123456789', // Personal identifier
            unique_identifier: '987654321', // Unique identifier
        };

        let userEngagement = UserEngagement {
            location: 'Unknown', // Location
            education: 'CID-Education', // CID for education
            occupation: 'CID-Occupation', // CID for occupation
            employer: 'CID-Employer', // CID for employer
            marital_status: 'Single', // Marital status
        };

        let userFinancial = UserFinancial{
        user: userContractAddress,
        stark_worth: 0,
        
        };

        let person = Person {
            user_spine: userSpine,
            user_experience: userExperience,
            user_identity: userIdentity,
            user_engagement: userEngagement,
            user_financial:userFinancial,
        };

        person

    }

    #[test]
    #[should_panic]
    #[available_gas(20000000)]
    fn test_person_tier_one() {
        // Set up.
        // let mut calldata: Array<felt252> = ArrayTrait::new();
        // let (address0, _) = deploy_syscall(SDIDContract::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false).unwrap();
        
        let mut contract = deploy();


        let person = person_data();
        // hashed data key
        let hashed_key = contract.set_person_tier_one(person);


        // Read the array.
        let person_tier = contract.get_person_tier(hashed_key);
        assert(person_tier == 1, 'read');


        let mut serialized_spine: Array<felt252> = ArrayTrait::new();
        Serde::<UserSpine>::serialize(@person.user_spine, ref serialized_spine);
        let hashed_spine = poseidon_hash_span(serialized_spine.span());

        let person_spine = contract.get_person_spine(hashed_key);

        assert(person_spine == hashed_spine, 'user spine');


        let person_experience  = contract.get_person_experience_data(hashed_key);

        let  hobbies_CID = person_experience.hobbies;
        

        assert( hobbies_CID == 'CID-Hobbies', 'person experience data');

        let person_engagement = contract.get_person_engagement_data(hashed_key);

        assert(person_engagement.employer == 'CID-Education', 'person engagement data');


        let person_identity = contract.get_person_identity_data(hashed_key);

        assert(person_identity.unique_identifier == '987654321','person_identy');

    }


    #[test]
    #[available_gas(20000000)]
    fn test_person_tier_four(){

        let mut contract = deploy();


        let person = person_data();
                // hashed data key
        let hashed_key_tier_four = contract.set_person_tier_four(person);

        // Read the array.
        let person_tier_four = contract.get_person_tier(hashed_key_tier_four);
        assert(person_tier_four == 4, 'read');


        let mut serialized_spine_tier_four: Array<felt252> = ArrayTrait::new();
        Serde::<UserSpine>::serialize(@person.user_spine, ref serialized_spine_tier_four);
        let hashed_spine_four = poseidon_hash_span(serialized_spine_tier_four.span());

        let person_spine_tier_four = contract.get_person_spine(hashed_key_tier_four);

        assert(person_spine_tier_four == hashed_spine_four, 'user spine');


        let person_experience_tier_four  = contract.get_person_experience_data(hashed_key_tier_four);

        let  hobbies_CID_tier_four = person_experience_tier_four.hobbies;
       

        assert( hobbies_CID_tier_four == 'CID-Hobbies', 'person experience data');

        let person_engagement_tier_four = contract.get_person_engagement_data(hashed_key_tier_four);
        

        assert(person_engagement_tier_four.education == 'CID-Education', 'person engagement data');


        let person_identity_tier_four = contract.get_person_identity_data(hashed_key_tier_four);

        assert(person_identity_tier_four.unique_identifier == '987654321','person_identy');
    }
}
