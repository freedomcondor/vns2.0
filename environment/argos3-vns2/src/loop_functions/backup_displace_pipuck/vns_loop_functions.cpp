#include "vns_loop_functions.h"


namespace argos {

UInt32 stepcount = 0;

   /****************************************/
   /****************************************/

   CVNSLoopFunctions::CVNSLoopFunctions() {}

   /****************************************/
   /****************************************/

   void CVNSLoopFunctions::Init(TConfigurationNode& t_tree) {
      using TValueType = std::pair<const std::string, CAny>;
      /* create a vector of the drones */
      for(const TValueType& t_robot : GetSpace().GetEntitiesByType("drone")) {
         m_vecDrones.emplace_back(any_cast<CDroneEntity*>(t_robot.second));
      }
      /* create a vector of the pi-pucks */
      for(const TValueType& t_robot : GetSpace().GetEntitiesByType("pipuck")) {
         m_vecPiPucks.emplace_back(any_cast<CPiPuckEntity*>(t_robot.second));
      }

	  stepcount = 0;
	  m_pcRNG = CRandom::CreateRNG("argos");
   }

   /****************************************/
   /****************************************/

   void CVNSLoopFunctions::Reset() {
      for(SDrone& s_drone : m_vecDrones) {
         s_drone.OutputFileStream.close();
         s_drone.OutputFileStream.clear();
         s_drone.OutputFileStream.open(s_drone.Entity->GetId() + ".csv",
                                       std::ios_base::out | std::ios_base::trunc);
      }
      for(SPiPuck& s_pipuck : m_vecPiPucks) {
         s_pipuck.OutputFileStream.close();
         s_pipuck.OutputFileStream.clear();
         s_pipuck.OutputFileStream.open(s_pipuck.Entity->GetId() + ".csv",
                                        std::ios_base::out | std::ios_base::trunc);
      }

	  stepcount = 0;
   }

   /****************************************/
   /****************************************/

   void CVNSLoopFunctions::PostStep() {
      UInt32 unTime = GetSpace().GetSimulationClock();
      /* write the positions of all robots to an output file */
      for(SDrone& s_drone : m_vecDrones) {
         const CVector3& cDronePosition =
            s_drone.Entity->GetEmbodiedEntity().GetOriginAnchor().Position;
         const CQuaternion& cDroneOrientation =
            s_drone.Entity->GetEmbodiedEntity().GetOriginAnchor().Orientation;
         std::string strOutputBuffer(s_drone.Entity->GetDebugEntity().GetBuffer("loop_functions"));
         strOutputBuffer.erase(std::remove(std::begin(strOutputBuffer),
                                           std::end(strOutputBuffer),
                                           '\n'),
                               std::end(strOutputBuffer));
         s_drone.OutputFileStream << unTime << ","
                                  << cDronePosition << ","
                                  << cDroneOrientation << ","
                                  << strOutputBuffer << std::endl;
      }
      for(SPiPuck& s_pipuck : m_vecPiPucks) {
         const CVector3& cPiPuckPosition =
            s_pipuck.Entity->GetEmbodiedEntity().GetOriginAnchor().Position;
         const CQuaternion& cPiPuckOrientation =
            s_pipuck.Entity->GetEmbodiedEntity().GetOriginAnchor().Orientation;
         std::string strOutputBuffer(s_pipuck.Entity->GetDebugEntity().GetBuffer("loop_functions"));
         strOutputBuffer.erase(std::remove(std::begin(strOutputBuffer),
                                           std::end(strOutputBuffer),
                                           '\n'),
                               std::end(strOutputBuffer));
         s_pipuck.OutputFileStream << unTime << ","
                                   << cPiPuckPosition << ","
                                   << cPiPuckOrientation << ","
                                   << strOutputBuffer << std::endl;
      }

      if (stepcount == 1500) {
         //int robot_index = m_pcRNG->Uniform(CRange<UInt32>(2, 21));
         //int robot_index = m_pcRNG->Uniform(CRange<UInt32>(2, 7));
         int robot_index = m_pcRNG->Uniform(CRange<UInt32>(1, 15));
         std::ostringstream robot_name;
         robot_name << "pipuck" << robot_index;
         std::cout << robot_name.str() << std::endl;

         DistanceFile.close();
         DistanceFile.clear();
         DistanceFile.open("distance.csv",
                           std::ios_base::out | std::ios_base::trunc);

         for(SPiPuck& s_pipuck : m_vecPiPucks) {
            if (s_pipuck.Entity->GetId() == robot_name.str()) {
               bool flag = false;
               while (flag == false) {
                  Real x_number = m_pcRNG->Uniform(CRange<Real>(-3.7, 0.7));
                  Real y_number = m_pcRNG->Uniform(CRange<Real>(-0.7, 0.7));
                  if ((-1.7 < x_number) && (x_number < -0.3))
                     y_number = m_pcRNG->Uniform(CRange<Real>(-1.7, 1.7));
                  Real distance = (s_pipuck.Entity->GetEmbodiedEntity().GetOriginAnchor().Position - 
                                  CVector3(x_number,y_number,0)).Length();
                  DistanceFile << distance << std::endl;
                  flag = MoveEntity(s_pipuck.Entity->GetEmbodiedEntity(), 
                                    CVector3(x_number,y_number,0.01), 
                                    CQuaternion(1,0,0,0), 
                                    false);
               }
            }
         }
      }

      stepcount++;
   }

   /****************************************/
   /****************************************/

   CColor CVNSLoopFunctions::GetFloorColor(const CVector2& c_position) {
      return CColor::GRAY90;
   }

   /****************************************/
   /****************************************/

   REGISTER_LOOP_FUNCTIONS(CVNSLoopFunctions, "vns_loop_functions");

}
