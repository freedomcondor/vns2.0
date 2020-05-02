#ifndef VNS_LOOP_FUNCTIONS_H
#define VNS_LOOP_FUNCTIONS_H

#include <argos3/core/simulator/loop_functions.h>

#include <argos3/plugins/robots/pi-puck/simulator/pipuck_entity.h>
#include <argos3/plugins/robots/drone/simulator/drone_entity.h>
#include <argos3/plugins/simulator/entities/debug_entity.h>

#include <fstream>
#include <string>
#include <vector>

namespace argos {

   class CVNSLoopFunctions : public CLoopFunctions {

   public:

      CVNSLoopFunctions();

      virtual ~CVNSLoopFunctions() {}

      virtual void Init(TConfigurationNode& t_tree) override;

      virtual void Reset() override;

      virtual void PostStep() override;

      virtual CColor GetFloorColor(const CVector2& c_position) override;

   private:
      struct SDrone {
         SDrone(CDroneEntity* pc_entity) :
            Entity(pc_entity),
            OutputFileStream(pc_entity->GetId() + ".csv",
                             std::ios_base::out | std::ios_base::trunc) {
            OutputFileStream << std::setprecision(3) << std::fixed;
         }
         CDroneEntity* Entity;
         std::ofstream OutputFileStream;
      };

      struct SPiPuck {
         SPiPuck(CPiPuckEntity* pc_entity) :
            Entity(pc_entity),
            OutputFileStream(pc_entity->GetId() + ".csv",
                             std::ios_base::out | std::ios_base::trunc)  {
            OutputFileStream << std::setprecision(3) << std::fixed;
         }
         CPiPuckEntity* Entity;
         std::ofstream OutputFileStream;
      };

      /* vectors of entities */
      //std::vector<SDrone> m_vecDrones;
      //std::vector<SPiPuck> m_vecPiPucks;
   };


}

#endif

