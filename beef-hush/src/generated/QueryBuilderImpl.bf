namespace Hush;
using System;
public static class QueryBuilderImpl {

		public static RawQuery InitQuery(void* scene, uint8* queryDesc) {
			return BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__impl__QueryBuilderImpl__InitQuery(scene, queryDesc);
		}

		public static void WithOptional(uint8* queryDesc, uint8* termCountRef, uint64 term) {
			BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__impl__QueryBuilderImpl__WithOptional(queryDesc, termCountRef, term);
		}

		public static void Without(uint8* queryDesc, uint8* termCountRef, uint64 term) {
			BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__impl__QueryBuilderImpl__Without(queryDesc, termCountRef, term);
		}

		public static void InitDescriptor(uint8* queryDesc, uint64* componentsData, uint64 componentsSize) {
			BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__impl__QueryBuilderImpl__InitDescriptor(queryDesc, componentsData, componentsSize);
		}

		public static void WithTerm(uint8* queryDesc, uint8* termCountRef, uint64 term) {
			BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__impl__QueryBuilderImpl__WithTerm(queryDesc, termCountRef, term);
		}

		public static void WithRelationship(uint8* queryDesc, uint8* termCountRef, Entity* relationship) {
			BeefHush.EngineDependencies.Instance.FunctionPointerTable.HushFuncPtr_Hush__impl__QueryBuilderImpl__WithRelationship(queryDesc, termCountRef, relationship);
		}

}